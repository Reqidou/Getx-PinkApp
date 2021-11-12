import 'package:pink_acg/app/data/user_center_mo.dart';

class CommentMo {
  late List<CommentList> list;
  late int total;

  CommentMo({required this.list, required this.total});

  CommentMo.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <CommentList>[];
      json['list'].forEach((v) {
        list.add(new CommentList.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.list != null) {
      data['list'] = this.list.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    return data;
  }
}

class CommentList {
  late UserMeta owner;
  late int postId;
  late int userId;
  late String content;
  late String type;
  late int parent;
  late int likeNum;
  late String updatedTime;

  CommentList(
      {required this.owner,
      required this.postId,
      required this.userId,
      required this.content,
      required this.type,
      required this.parent,
      required this.likeNum,
      required this.updatedTime});

  CommentList.fromJson(Map<String, dynamic> json) {
    owner =
        (json['owner'] != null ? new UserMeta.fromJson(json['owner']) : null)!;
    postId = json['post_id'];
    userId = json['user_id'];
    content = json['content'];
    type = json['type'];
    parent = json['parent'];
    likeNum = json['like_num'];
    updatedTime = json['update_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.owner != null) {
      data['owner'] = this.owner.toJson();
    }
    data['post_id'] = this.postId;
    data['user_id'] = this.userId;
    data['content'] = this.content;
    data['type'] = this.type;
    data['parent'] = this.parent;
    data['like_num'] = this.likeNum;
    data['update_time'] = this.updatedTime;
    return data;
  }
}
