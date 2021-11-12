import 'dart:math';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pink_acg/app/data/post_mo.dart';
import 'package:pink_acg/app/data/video_detail_mo.dart';
import 'package:pink_acg/app/http/dao/comment_dao.dart';
import 'package:pink_acg/app/http/dao/video_detail_dao.dart';
import 'package:pink_acg/app/lib/fijkplayer_skin/fijkplayer_skin.dart';
import 'package:pink_acg/app/lib/fijkplayer_skin/schema.dart';
import 'package:pink_acg/app/util/color.dart';
import 'package:pink_acg/app/util/follow.dart';
import 'package:pink_acg/app/util/screenutil.dart';
import 'package:pink_acg/app/util/toast.dart';
import 'package:pink_acg/app/util/video_analysis.dart';
import 'package:pink_acg/app/util/view_util.dart';
import 'package:pink_acg/app/widget/card/video_large_card.dart';
import 'package:pink_acg/app/widget/loading_container.dart';
import 'package:pink_acg/app/widget/navigation_bar.dart';
import 'package:pink_acg/app/widget/pink_tab.dart';
import 'package:pink_acg/app/widget/share_card.dart';
import 'package:pink_acg/app/widget/tab/comment_tab_page.dart';
import 'package:pink_acg/app/widget/video_content.dart';
import 'package:pink_acg/app/widget/video_header.dart';
import 'package:pink_acg/app/widget/video_player.dart';
import 'package:pink_acg/app/widget/video_toolbar.dart';
import 'package:pink_net/core/pink_error.dart';

class VideoView extends StatefulWidget {
  const VideoView({Key? key}) : super(key: key);

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController controller;
  List tabs = ["简介", "评论"];
  VideoDetailMo videoDetailMo = VideoDetailMo();
  List<PostMo> videoList = <PostMo>[];
  PostMo contentModel = PostMo(
      video: Collection(video: <VideoCollection>[
    VideoCollection(list: [CollectionList()])
  ]));

  bool inoutShowing = false;
  late TextEditingController textEditingController;
  int curTabIdx = 0;
  int curActiveIdx = 0;

  int random = 0;

  // FijkPlayer实例
  FijkPlayer player = FijkPlayer();
  ShowConfigAbs vCfg = PlayerShowConfig();
  VideoSourceFormat? videoSourceTabs;

  Collection collection = Collection(video: <VideoCollection>[
    VideoCollection(list: [CollectionList()])
  ]);

  // 播放器内部切换视频钩子，回调，tabIdx 和 activeIdx
  void onChangeVideo(int _curTabIdx, int _curActiveIdx) async {
    curTabIdx = _curTabIdx;
    curActiveIdx = _curActiveIdx;
  }

  videoFormat() async {
    var video = contentModel.video.video[0].list[0].url;
    if (video.startsWith('https://www.douyin.com')) {
      var url = await getHttp(video);
      contentModel.video.video[0].list[0].url = url;
    } else if (video.startsWith('https://www.bilibili.com/video/')) {
      var url = await getHttp2(video);
      contentModel.video.video[0].list[0].url = url;
    }
    await player.setOption(FijkOption.formatCategory, "headers",
        "referer:${contentModel.video.video[0].list[0].url}");
    // 格式化json转对象
    setState(() {
      videoSourceTabs = VideoSourceFormat.fromJson(contentModel.video.toJson());
    });
  }

  Future<void> send(String value) async {
    try {
      if (value.isNotEmpty) {
        textEditingController.text = "";
        var result = await CommentDao.post(contentModel.postId, value, "post");
        if (result["code"] == 1000) {
          random = Random().nextInt(100);
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
          await VideoDetailDao.get(contentModel.postId.toString());
      setState(() {
        videoDetailMo = result;
        contentModel = result.postInfo!;
        videoList = result.postList!;
      });
      addPostView(contentModel.postId);
    } on NeedLogin catch (e) {
      showWarnToast(e.message);
    } on NeedAuth catch (e) {
      showWarnToast(e.message);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      //处于这种状态的应用程序应该假设它们可能在任何时候暂停
      case AppLifecycleState.inactive:
        player.dispose();
        break;
      //从后台切换前台，界面可见
      case AppLifecycleState.resumed:
        player.start();
        break;
      //界面不可见，后台
      case AppLifecycleState.paused:
        player.stop();
        break;
      //App结束调用
      case AppLifecycleState.detached:
        player.dispose();
        break;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    contentModel = (Get.arguments as Map)["contentModel"];
    var awaitWatch = GetStorage().read("historyWatchPost");
    if (awaitWatch != null && awaitWatch.length > 0) {
      if (!awaitWatch.contains("${contentModel.postId}")) {
        awaitWatch.insert(0, "${contentModel.postId}");
      }
      GetStorage().write("historyWatchPost", awaitWatch);
    } else {
      GetStorage().write("historyWatchPost", ["${contentModel.postId}"]);
    }
    textEditingController = TextEditingController();
    controller = TabController(length: tabs.length, vsync: this);
    Future.delayed(Duration(milliseconds: 500), () {
      loadDetail();
      videoFormat();
    });
    // 这句不能省，必须有
    speed = 1.0;
    collection = contentModel.video;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    player.dispose();
    controller.dispose();
    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MediaQuery.removePadding(
      removeTop: GetPlatform.isIOS,
      context: context,
      child: Column(
        children: [
          NavigationBar(
            color: Colors.black,
            statusStyle: StatusStyle.LIGHT_CONTENT,
            height: GetPlatform.isAndroid ? setHeight(16) : setHeight(80),
          ),
          _buildVideoView(),
          _buildTabNavigation(),
          _buildTabView(),
        ],
      ),
    ));
  }

  _buildInput(BuildContext context) {
    return Expanded(
        child: Container(
      height: setHeight(90),
      margin: EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(26)),
      child: TextField(
        controller: textEditingController,
        onSubmitted: (value) {
          send(value);
        },
        cursorColor: primary,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          border: InputBorder.none,
          hintStyle: TextStyle(
            fontSize: 13,
            color: Color.fromRGBO(146, 156, 149, 1),
          ),
          hintText: "发送一条评论!",
        ),
      ),
    ));
  }

  _buildSendBtn(BuildContext context) {
    return InkWell(
      onTap: () {
        var text = textEditingController.text.isNotEmpty
            ? textEditingController.text.trim()
            : "";
        send(text);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: Icon(
          Icons.send_rounded,
          color: primary,
        ),
      ),
    );
  }

  _buildVideoView() {
    return contentModel.video.toJson() != {} &&
            contentModel.video.toJson() != null
        ? LoadingContainer(
            isLoading: videoSourceTabs == null,
            top: setHeight(150),
            child: Container(
                height: setR(620),
                alignment: Alignment.center,
                // 这里 FijkView 开始为自定义 UI 部分
                child: FijkView(
                  height: setR(620),
                  color: Colors.black,
                  fit: FijkFit.cover,
                  player: player,
                  panelBuilder: (
                    FijkPlayer player,
                    FijkData data,
                    BuildContext context,
                    Size viewSize,
                    Rect texturePos,
                  ) {
                    if (videoSourceTabs != null) {
                      /// 使用自定义的布局
                      return CustomFijkPanel(
                        player: player,
                        // 传递 context 用于左上角返回箭头关闭当前页面，不要传递错误 context，
                        // 如果要点击箭头关闭当前的页面，那必须传递当前组件的根 context
                        pageContent: context,
                        viewSize: viewSize,
                        texturePos: texturePos,
                        // 标题 当前页面顶部的标题部分，可以不传，默认空字符串
                        playerTitle: "${contentModel.title}",
                        // 当前视频改变钩子，简单模式，单个视频播放，可以不传
                        onChangeVideo: onChangeVideo,
                        // 当前视频源tabIndex
                        curTabIdx: curTabIdx,
                        // 当前视频源activeIndex
                        curActiveIdx: curActiveIdx,
                        // 显示的配置
                        showConfig: vCfg,
                        // json格式化后的视频数据
                        videoFormat: videoSourceTabs,
                      );
                    } else {
                      return Container();
                    }
                  },
                )),
          )
        : Container();
  }

  _buildTabNavigation() {
    return Container(
      decoration: bottomBoxShadow(),
      height: setHeight(108),
      padding: EdgeInsets.only(left: setWidth(100)),
      alignment: Alignment.centerLeft,
      child: _tabBar(),
    );
  }

  _tabBar() {
    return PinkTab(
      tabs: tabs.map<Tab>((tab) {
        return Tab(
          text: tab,
        );
      }).toList(),
      labelFontSize: setSp(35),
      unselectedFontSize: setSp(35),
      controller: controller,
    );
  }

  _buildDetailList(context) {
    return ListView(
      padding: EdgeInsets.only(top: setHeight(30)),
      children: [
        Container(
          margin: EdgeInsets.only(bottom: setHeight(35), left: setHeight(20)),
          child: VideoHeader(
            userMeta: contentModel.userMeta,
            time: contentModel.createTime,
            isFollow: videoDetailMo.isFollow,
            isSelf: videoDetailMo.isSelf,
            onFollow: videoDetailMo.isFollow
                ? () {
                    unFollow(contentModel.userMeta!.userId, () {
                      setState(() {
                        videoDetailMo.isFollow = false;
                      });
                    });
                  }
                : () {
                    follow(contentModel.userMeta!.userId, () {
                      setState(() {
                        videoDetailMo.isFollow = true;
                      });
                    });
                  },
          ),
        ),
        VideoContent(mo: contentModel),
        VideoToolBar(
          detailMo: videoDetailMo,
          contentModel: contentModel,
          onLike: () {
            doLike(contentModel.postId, () {
              setState(() {
                videoDetailMo.isLike = true;
                videoDetailMo.isUnLike = false;
                if (contentModel.likes >= 0) {
                  contentModel.likes += 1;
                }
                if (contentModel.un_likes >= 1) {
                  contentModel.un_likes -= 1;
                }
              });
            });
          },
          onUnLike: () {
            doUnLike(contentModel.postId, () {
              setState(() {
                videoDetailMo.isLike = false;
                videoDetailMo.isUnLike = true;
                if (contentModel.likes >= 1) {
                  contentModel.likes -= 1;
                }
                if (contentModel.un_likes >= 0) {
                  contentModel.un_likes += 1;
                }
              });
            });
          },
          onFavorite: () {
            onFavorite(videoDetailMo.isFavorite, contentModel.postId, () {
              if (videoDetailMo.isFavorite) {
                setState(() {
                  videoDetailMo.isFavorite = false;
                  if (contentModel.favorite >= 1) {
                    contentModel.favorite -= 1;
                  }
                });
                showToast("取消收藏成功!");
              } else {
                videoDetailMo.isFavorite = true;
                if (contentModel.favorite >= 0) {
                  setState(() {
                    contentModel.favorite += 1;
                  });
                }
                showToast("收藏成功!");
              }
            });
          },
          onCoin: () {
            onCoin(contentModel.postId, () {
              setState(() {
                videoDetailMo.isCoin = true;
                contentModel.coin += 1;
              });
            });
          },
          onShare: () {
            moreHandleDialog(context, 720, ShareCard(postMo: contentModel));
          },
        ),
        Container(
          height: setHeight(200),
          padding: EdgeInsets.only(
              left: setWidth(20),
              right: setWidth(20),
              top: setHeight(35),
              bottom: setHeight(35)),
          child: collection != null
              ? ListView(
                  scrollDirection: Axis.horizontal,
                  children: collection.video[0].list.asMap().entries.map((e) {
                    return Container(
                      height: setHeight(120),
                      width: setWidth(340),
                      margin: EdgeInsets.only(
                        left: setWidth(15),
                        right: setWidth(15),
                      ),
                      child: TextButton(
                        style: ButtonStyle(
                          //定义文本的样式 这里设置的颜色是不起作用的
                          textStyle: MaterialStateProperty.all(
                              TextStyle(fontSize: 18, color: Colors.red)),
                          //设置按钮上字体与图标的颜色
                          //foregroundColor: MaterialStateProperty.all(Colors.deepPurple),
                          //更优美的方式来设置
                          foregroundColor: MaterialStateProperty.resolveWith(
                            (states) {
                              if (states.contains(MaterialState.focused) &&
                                  !states.contains(MaterialState.pressed)) {
                                //获取焦点时的颜色
                                return Colors.grey;
                              } else if (states
                                  .contains(MaterialState.pressed)) {
                                //按下时的颜色
                                return Colors.grey;
                              }
                              //默认状态使用灰色
                              return Colors.grey;
                            },
                          ),
                          //背景颜色
                          backgroundColor:
                              MaterialStateProperty.resolveWith((states) {
                            //设置按下时的背景颜色
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.white;
                            }
                            //默认不使用背景颜色
                            return null;
                          }),
                          //设置水波纹颜色
                          overlayColor: MaterialStateProperty.all(Colors.white),
                          //设置阴影  不适用于这里的TextButton
                          elevation: MaterialStateProperty.all(0),
                          //设置按钮内边距
                          padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                          //设置按钮的大小
                          minimumSize:
                              MaterialStateProperty.all(Size(200, 100)),

                          //设置边框
                          side: MaterialStateProperty.all(BorderSide(
                              color: curTabIdx == 0 && curActiveIdx == e.key
                                  ? primary
                                  : Color.fromRGBO(236, 236, 236, 1),
                              width: setWidth(3))),
                        ),
                        child: Container(
                          padding: EdgeInsets.only(
                              left: setWidth(25), right: setWidth(25)),
                          child: Text(
                            '${e.key} - ${e.value.name}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: setSp(32),
                                color: curTabIdx == 0 && curActiveIdx == e.key
                                    ? primary
                                    : Colors.black),
                          ),
                        ),
                        onPressed: () async {
                          await player.reset();
                          setState(() {
                            curActiveIdx = e.key;
                            player.setDataSource(
                                contentModel.video.video[curTabIdx]
                                    .list[curActiveIdx].url,
                                autoPlay: true);
                          });
                        },
                      ),
                    );
                  }).toList(),
                )
              : Container(),
        ),
        ..._buildVideoList(context)
      ],
    );
  }

  _buildVideoList(context) {
    return videoList.map(
      (PostMo mo) => VideoLargeCard(player: player, contentModel: mo),
    );
  }

  _buildTabView() {
    return Flexible(
        child: TabBarView(
      controller: controller,
      children: [
        _buildDetailList(context),
        Column(
          children: [
            Expanded(
              child: CommentTabPage(
                postId: contentModel.postId,
                content: "$random",
              ),
            ),
            Container(
              color: Colors.white,
              child: Row(
                children: [_buildInput(context), _buildSendBtn(context)],
              ),
            ),
          ],
        ),
      ],
    ));
  }
}
