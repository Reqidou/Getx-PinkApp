import 'package:pink_acg/app/data/post_mo.dart';

class VideoDetailMo {
  late bool isFavorite;
  late bool isSelf;
  late bool isFollow;
  late bool isCoin;
  late bool isLike;
  late bool isUnLike;
  late PostMo? postInfo;
  late List<PostMo>? postList;

  VideoDetailMo(
      {this.isFavorite = false,
      this.isSelf = false,
      this.isFollow = false,
      this.isCoin = false,
      this.isLike = false,
      this.isUnLike = false,
      this.postInfo,
      this.postList});

  VideoDetailMo.fromJson(Map<String, dynamic> json) {
    isFavorite = json['isFavorite'];
    isSelf = json['isSelf'];
    isFollow = json['isFollow'];
    isCoin = json['isCoin'];
    isLike = json['isLike'];
    isUnLike = json['isUnLike'];
    postInfo = (json['postInfo'] != null
        ? new PostMo.fromJson(json['postInfo'])
        : null)!;
    if (json['postList'] != null) {
      postList = <PostMo>[];
      json['postList'].forEach((v) {
        postList!.add(new PostMo.fromJson(v));
      });
    } else {
      postList = <PostMo>[];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isFavorite'] = this.isFavorite;
    data['isSelf'] = this.isSelf;
    data['isFollow'] = this.isFollow;
    data['isCoin'] = this.isCoin;
    data['isLike'] = this.isLike;
    data['isUnLike'] = this.isUnLike;
    if (this.postInfo != null) {
      data['postInfo'] = this.postInfo!.toJson();
    }
    if (this.postList != null) {
      data['postList'] = this.postList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Collection {
  List<VideoCollection> video = <VideoCollection>[];

  Collection({required this.video});

  Collection.fromJson(Map<String, dynamic> json) {
    if (json['video'] != null) {
      video = <VideoCollection>[];
      json['video'].forEach((v) {
        video.add(new VideoCollection.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.video != null) {
      data['video'] = this.video.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VideoCollection {
  String name = "";
  List<CollectionList> list = <CollectionList>[];

  VideoCollection({this.name = "", required this.list});

  VideoCollection.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['list'] != null) {
      list = <CollectionList>[];
      json['list'].forEach((v) {
        list.add(new CollectionList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.list != null) {
      data['list'] = this.list.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CollectionList {
  String url = "";
  String name = "";

  CollectionList({this.url = "", this.name = ""});

  CollectionList.fromJson(Map<String, dynamic> json) {
    if (json['name'] != null) {
      url = json['url'];
    }
    if (json['name'] != null) {
      name = json['name'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['name'] = this.name;
    return data;
  }
}
