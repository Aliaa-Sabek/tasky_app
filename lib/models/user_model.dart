class AppUser {
  final String uid;
  final String email;
  final String? name;
  final String? photoUrl;

  AppUser({
    required this.uid,
    required this.email,
    this.name,
    this.photoUrl,
  });

  
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }

 
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      photoUrl: json['photoUrl'],
    );
  }
}
