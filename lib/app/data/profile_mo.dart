class ProfileMo {
  late int userId;
  late String avatar;
  late String background;
  late String username;
  late int fans;
  late int follows;
  late int coin;
  late int active;

  ProfileMo(
      {required this.userId,
      required this.avatar,
      required this.background,
      required this.username,
      required this.fans,
      required this.follows,
      required this.coin,
      required this.active});

  ProfileMo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    avatar = json['avatar'];
    background = json['background'];
    username = json['username'];
    fans = json['fans'];
    follows = json['follows'];
    coin = json['coin'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['avatar'] = this.avatar;
    data['background'] = this.background;
    data['username'] = this.username;
    data['fans'] = this.fans;
    data['follows'] = this.follows;
    data['coin'] = this.coin;
    data['active'] = this.active;
    return data;
  }
}
