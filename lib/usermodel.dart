class Usermodel {
  String? uid;
  String? email;
  String? name;
  String? number;
  String? profileImageUrl;

  Usermodel(
      {this.uid, this.email, this.name, this.number, this.profileImageUrl});

  factory Usermodel.fromMap(map) {
    return Usermodel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      number: map['number'],
      profileImageUrl: map['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'number': number,
      'profileImageUrl': profileImageUrl,
    };
  }
}
