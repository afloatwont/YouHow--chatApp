class UserProfile {
  String? uid;
  String? name;
  String? pfpURL;
  String? number;
  String? email;
  List<String>? friends;

  UserProfile({
    required this.uid,
    required this.name,
    required this.pfpURL,
    required this.number,
    required this.email,
    this.friends,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    pfpURL = json['pfpURL'];
    number = json['number'];
    email = json['email'];
    friends = json['Friends'] != null ? List<String>.from(json['Friends'].map((friend) => friend.toString())) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['pfpURL'] = pfpURL;
    data['uid'] = uid;
    data['email'] = email;
    data['number'] = number;
    data['Friends'] = friends;
    return data;
  }
}
