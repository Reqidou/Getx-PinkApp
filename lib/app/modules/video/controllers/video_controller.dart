import 'dart:math';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pink_acg/app/data/post_mo.dart';
import 'package:pink_acg/app/data/video_detail_mo.dart';
import 'package:pink_acg/app/http/dao/comment_dao.dart';
import 'package:pink_acg/app/http/dao/video_detail_dao.dart';
import 'package:pink_acg/app/lib/fijkplayer_skin/fijkplayer_skin.dart';
import 'package:pink_acg/app/lib/fijkplayer_skin/schema.dart';
import 'package:pink_acg/app/util/toast.dart';
import 'package:pink_acg/app/util/video_analysis.dart';
import 'package:pink_acg/app/util/view_util.dart';
import 'package:pink_acg/app/widget/video_player.dart';
import 'package:pink_net/core/pink_error.dart';

class VideoController extends GetxController with SingleGetTickerProviderMixin {
  //TODO: Implement VideoController
  late TabController controller;
  List tabs = ["简介", "评论"];
  var videoDetailMo = VideoDetailMo().obs;
  var videoList = <PostMo>[].obs;
  var contentModel = PostMo(
      video: Collection(video: <VideoCollection>[
    VideoCollection(list: [CollectionList()])
  ])).obs;

  bool inoutShowing = false;
  late TextEditingController textEditingController;
  var curTabIdx = 0.obs;
  var curActiveIdx = 0.obs;
  var random = 0.obs;
  // FijkPlayer实例
  var player = FijkPlayer().obs;
  ShowConfigAbs vCfg = PlayerShowConfig();
  VideoSourceFormat? videoSourceTabs;

  var collection = Collection(video: <VideoCollection>[
    VideoCollection(list: [CollectionList()])
  ]).obs;

  // 播放器内部切换视频钩子，回调，tabIdx 和 activeIdx
  void onChangeVideo(int _curTabIdx, int _curActiveIdx) async {
    curTabIdx.value = _curTabIdx;
    curActiveIdx.value = _curActiveIdx;
  }

  videoFormat() async {
    var video = contentModel.value.video.video[0].list[0].url;
    if (video.startsWith('https://www.douyin.com')) {
      var url = await getHttp(video);
      contentModel.value.video.video[0].list[0].url = url;
      contentModel.update((val) {
        val!.video.video[0].list[0].url = url;
      });
      await player.value.stop();
      await player.value.reset();
      player.value.setDataSource(
          contentModel
              .value.video.video[curTabIdx.value].list[curActiveIdx.value].url,
          autoPlay: true);
    } else if (video.startsWith('https://www.acfun.cn/v/')) {
      var url = await getHttp2(video);
      contentModel.value.video.video[0].list[0].url = url;
      contentModel.update((val) {
        val!.video.video[0].list[0].url = url;
      });
      await player.value.stop();
      await player.value.reset();
      player.value.setDataSource(
          contentModel
              .value.video.video[curTabIdx.value].list[curActiveIdx.value].url,
          autoPlay: true);
    }
  }

  Future<void> send(String value) async {
    try {
      if (value.length > 0) {
        textEditingController.text = "";
        var result =
            await CommentDao.post(contentModel.value.postId, value, "post");
        if (result["code"] == 1000) {
          random.value = Random().nextInt(100);
          showToast("评论成功");
        } else {
          showWarnToast(result['msg']);
        }
      } else {
        showWarnToast("评论为空");
      }
    } on NeedLogin catch (e) {
      showWarnToast(e.message);
    } on NeedAuth catch (e) {
      showWarnToast(e.message);
    }
  }

  void loadDetail() async {
    try {
      VideoDetailMo result =
          await VideoDetailDao.get(contentModel.value.postId.toString());
      videoDetailMo.value = result;
      contentModel.value = result.postInfo!;
      videoList.value = result.postList!;
      addPostView(contentModel.value.postId);
    } on NeedLogin catch (e) {
      showWarnToast(e.message);
    } on NeedAuth catch (e) {
      showWarnToast(e.message);
    }
  }

  @override
  void onInit() {
    contentModel.value = (Get.arguments as Map)["contentModel"];
    var awaitWatch = GetStorage().read("historyWatchPost");
    if (awaitWatch != null && awaitWatch.length > 0) {
      if (!awaitWatch.contains("${contentModel.value.postId}")) {
        awaitWatch.insert(0, "${contentModel.value.postId}");
      }
      GetStorage().write("historyWatchPost", awaitWatch);
    } else {
      GetStorage().write("historyWatchPost", ["${contentModel.value.postId}"]);
    }
    textEditingController = TextEditingController();
    controller = TabController(length: tabs.length, vsync: this);
    loadDetail();
    // 格式化json转对象
    videoSourceTabs =
        VideoSourceFormat.fromJson(contentModel.value.video.toJson());
    // 这句不能省，必须有
    speed = 1.0;
    collection.value = contentModel.value.video;
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    // player.value.dispose();
    controller.dispose();
    // textEditingController.dispose();
  }
}
