import 'package:cloud_firestore/cloud_firestore.dart';

class Photomodel {
  String? uid;
  String? fid;
  String? fname;

  Photomodel({this.uid, this.fid, this.fname});

  factory Photomodel.fromMap(map) {
    return Photomodel(
      uid: map['uid'],
      fid: map['fid'],
      fname: map['fname'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fid': fid,
      'fname': fname,
    };
  }

  factory Photomodel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return Photomodel(uid: data["uid"], fid: data["fid"], fname: data["fname"]);
  }
}
