class ChatUser {
  ChatUser({
    required this.image,
    required this.name,
    required this.about,
    required this.createdAt,
    required this.id,
    required this.lastActive,
    required this.isOnline,
    required this.pushToken,
    required this.email,
    required this.blockedUsers,
    required this.pinneduser,
    

  });
  late final String image;
  late  String name;
  late  String about;
  late final String createdAt;
  late final String id;
  late final String lastActive;
  late final bool isOnline;
  late final String pushToken;
  late final String email;
  late List<String> blockedUsers;
  late bool pinneduser;
  
  ChatUser.fromJson(Map<String, dynamic> json){
    image = json['image']??'';
    name = json['name']??'';
    about = json['about']??'';
    createdAt = json['created_at']??'';
    id = json['id'];
    lastActive = json['last_active']??'';
    isOnline = json['is_online']??'';
    pushToken = json['push_token']??'';
    email = json['email'];
    blockedUsers = List<String>.from(json['blockedUsers'] ?? []);
    pinneduser=json["pinneduser"] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['about'] = about;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['is_online'] = isOnline;
    data['push_token'] = pushToken;
    data['email'] = email;
    data['blockedUsers']= blockedUsers;
    data['pinneduser']=pinneduser;
    return data;
  }
}