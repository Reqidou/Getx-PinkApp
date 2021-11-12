import 'dart:convert';

import 'package:pink_acg/app/data/user_center_mo.dart';
import 'package:pink_acg/app/data/video_detail_mo.dart';

class PostMo {
  late UserMeta? userMeta;
  late int postId;
  late int authorId;
  late String postType;
  late String categorySlug;
  late String title;
  late String content;
  late int reply;
  late int favorite;
  late int likes;
  late int un_likes;
  late int coin;
  late int share;
  late int view;
  late String cover;
  late Collection video;
  late String download;
  late String createTime;
  late String updateTime;

  PostMo(
      {this.postId = 0,
      this.userMeta,
      this.authorId = 0,
      this.postType = "",
      this.categorySlug = "",
      this.title = "",
      this.content = "",
      this.reply = 0,
      this.favorite = 0,
      this.likes = 0,
      this.un_likes = 0,
      this.coin = 0,
      this.share = 0,
      this.view = 0,
      this.cover = "",
      required this.video,
      this.download = "",
      this.createTime = "",
      this.updateTime = ""});

  PostMo.fromJson(Map<String, dynamic> json) {
    userMeta =
        (json['owner'] != null ? new UserMeta.fromJson(json['owner']) : null)!;
    postId = json['post_id'];
    authorId = json['author_id'];
    postType = json['post_type'];
    categorySlug = json['category_slug'];
    title = json['title'];
    content = json['content'];
    reply = json['reply'];
    favorite = json['favorite'];
    likes = json['likes'];
    un_likes = json['un_likes'];
    coin = json['coin'];
    share = json['share'];
    view = json['view'];
    cover = json['cover'];
    video = (json['video'] != null
        ? new Collection.fromJson(jsonDecode(json['video']))
        : null)!;
    download = json['download'];
    createTime = json['create_time'];
    updateTime = json['update_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userMeta != null) {
      data['owner'] = this.userMeta!.toJson();
    }
    data['post_id'] = this.postId;
    data['author_id'] = this.authorId;
    data['post_type'] = this.postType;
    data['category_slug'] = this.categorySlug;
    data['title'] = this.title;
    data['content'] = this.content;
    data['reply'] = this.reply;
    data['favorite'] = this.favorite;
    data['likes'] = this.likes;
    data['un_likes'] = this.un_likes;
    data['coin'] = this.coin;
    data['share'] = this.share;
    data['view'] = this.view;
    data['cover'] = this.cover;
    if (this.video != null) {
      data['video'] = this.video.toJson();
    }
    data['download'] = this.download;
    data['create_time'] = this.createTime;
    data['update_time'] = this.updateTime;
    return data;
  }
}
