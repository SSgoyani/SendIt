import 'dart:io';
import 'dart:async';
import 'package:cardone1/View/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cardone1/loginscreen.dart';
import 'package:cardone1/homescreen.dart';
import 'package:cardone1/usermodel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

final FirebaseAuth _auth = FirebaseAuth.instance;
final firestoreInstance = FirebaseFirestore.instance;

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final picker = ImagePicker();
  XFile? _image;
  XFile? get image => _image;

  User? user = FirebaseAuth.instance.currentUser;
  Usermodel loggedInUser = Usermodel();
  String namefield = '';
  String emailfield = '';
  String phonefield = '';
  String aboutfield = '';
  String documentId = '';
  String _profileImageUrl = '';
  final CollectionReference myCollection =
      FirebaseFirestore.instance.collection('users');

  late DatabaseReference dbref;
  Stream<DocumentSnapshot> getUserStream() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    dbref = FirebaseDatabase.instance.ref().child('users');

    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = Usermodel.fromMap(value.data());
      setState(() {
        this.loggedInUser = Usermodel.fromMap(value.data()!);
        this.namefield = loggedInUser.name!;
        this.emailfield = loggedInUser.email!;
        this.phonefield = loggedInUser.number!;
        this.documentId = loggedInUser.uid!;
        this._profileImageUrl = loggedInUser.profileImageUrl!;
      });
    });
  }

  Future pickImage(BuildContext context) async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);

    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
        uploadImage(context);
      });
    }
  }

  Future uploadImage(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                backgroundColor: Colors.greenAccent.withOpacity(0.01),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(width: 8),
              Text(
                "Updating Image...",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
    String fileName = Path.basename(image!.path);
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('profile_images/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(File(image!.path));
    TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      // Update user document in Firestore with new image URL
      myCollection.doc(user!.uid).update({'profileImageUrl': downloadUrl});
      setState(() {
        _profileImageUrl = downloadUrl;
      });

      // Hide loading dialog
      Navigator.pop(context);
    });
  }

  void updateFirestoreName() async {
    await myCollection.doc(documentId).update({'name': namefield});
  }

  void updateFirestoreEmail() async {
    await myCollection.doc(documentId).update({'email': emailfield});
  }

  void updateFirestorePhone() async {
    await myCollection.doc(documentId).update({'number': phonefield});
  }

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  //TextEditingController _aboutController = new TextEditingController();

  void _updateName(String newValue) {
    setState(() {
      namefield = newValue;
    });
  }

  void _updateEmail(String newValue) {
    setState(() {
      emailfield = newValue;
    });
  }

  void _updatePhone(String newValue) {
    setState(() {
      phonefield = newValue;
    });
  }

  void _updateAbout(String newValue) {
    setState(() {
      aboutfield = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MyHomePage(),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.cyan,
          title: Text(
            'SendIt',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21,
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
        body: ListView(
          children: [
            Container(
              height: 250.0,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 170.0,
                    width: 170.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.cyan[100],
                      image: image != null
                          ? DecorationImage(
                              image: FileImage(File(_image!.path).absolute),
                              fit: BoxFit.cover,
                            )
                          : DecorationImage(
                              image: CachedNetworkImageProvider(
                                _profileImageUrl,
                              ),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(height: 1.0),
                  Container(
                    child: FloatingActionButton(
                      backgroundColor: Colors.indigo,
                      child: Icon(Icons.camera_alt_rounded),
                      onPressed: () {
                        pickImage(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.grey[200],
              height: 1,
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.person),
                        SizedBox(width: 10.0),
                        Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    'Change Name',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  content: TextField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter New Name',
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Save'),
                                      onPressed: () {
                                        var _name = _nameController.text;
                                        _updateName(_name);
                                        updateFirestoreName();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Icon(
                            Icons.edit,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    child: Text(
                      namefield,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    color: Colors.grey[200],
                    height: 1,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Row(
                      children: [
                        Icon(Icons.email),
                        SizedBox(width: 10.0),
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    'Change Email',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  content: TextField(
                                    keyboardType: TextInputType.emailAddress,
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter New Email',
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Save'),
                                      onPressed: () {
                                        var _email = _emailController.text;
                                        _updateEmail(_email);
                                        updateFirestoreEmail();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Icon(
                            Icons.edit,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    child: Text(
                      emailfield,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    color: Colors.grey[200],
                    height: 1,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.phone),
                        SizedBox(width: 10.0),
                        Text(
                          'Phone',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    'Change Phone',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  content: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: _phoneController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter New Phone',
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Save'),
                                      onPressed: () {
                                        var _phone = _phoneController.text;
                                        _updatePhone(_phone);
                                        updateFirestorePhone();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Icon(
                            Icons.edit,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    child: Column(
                      children: <Widget>[
                        Text(
                          phonefield,
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  // Container(
                  //   color: Colors.grey[200],
                  //   height: 1,
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  // Container(
                  //   child: Row(
                  //     children: <Widget>[
                  //       Icon(Icons.info_outline_rounded),
                  //       SizedBox(width: 10.0),
                  //       Text(
                  //         'About',
                  //         style: TextStyle(
                  //           fontSize: 16.0,
                  //           fontFamily: 'Poppins',
                  //         ),
                  //       ),
                  //       Container(
                  //         padding: EdgeInsets.symmetric(horizontal: 133),
                  //       ),
                  //       GestureDetector(
                  //         onTap: () {
                  //           showDialog(
                  //             context: context,
                  //             builder: (BuildContext context) {
                  //               return AlertDialog(
                  //                 title: Text('About'),
                  //                 content: TextField(
                  //                   controller: _aboutController,
                  //                   decoration: InputDecoration(
                  //                     hintText: 'About',
                  //                   ),
                  //                 ),
                  //                 actions: <Widget>[
                  //                   TextButton(
                  //                     child: Text('Cancel'),
                  //                     onPressed: () {
                  //                       Navigator.of(context).pop();
                  //                     },
                  //                   ),
                  //                   TextButton(
                  //                     child: Text('Save'),
                  //                     onPressed: () {
                  //                       var _about = _aboutController.text;
                  //                       _updateAbout(_about);
                  //                       Navigator.of(context).pop();
                  //                     },
                  //                   ),
                  //                 ],
                  //               );
                  //             },
                  //           );
                  //         },
                  //         child: Icon(
                  //           Icons.edit,
                  //           color: Colors.indigo,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(height: 5.0),
                  // Container(
                  //   padding: EdgeInsets.symmetric(horizontal: 35),
                  //   child: Column(
                  //     children: <Widget>[
                  //       Text(
                  //         aboutfield,
                  //         style: TextStyle(
                  //             fontSize: 18.0,
                  //             fontWeight: FontWeight.bold,
                  //             fontFamily: 'Poppins'),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  Container(
                    color: Colors.grey[200],
                    height: 1,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 7,
                  ),
                  Container(
                    width: 400,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              content: Container(
                                height: 130,
                                width: MediaQuery.of(context).size.width / 6,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        "Are you sure want to Logout?",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          style: ButtonStyle(
                                            fixedSize:
                                                MaterialStateProperty.all<Size>(
                                              Size(
                                                100,
                                                40,
                                              ),
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.indigo),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            "Log out",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          onPressed: () {
                                            FirebaseAuth.instance.signOut();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        const LoginScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                        ElevatedButton(
                                          style: ButtonStyle(
                                            fixedSize:
                                                MaterialStateProperty.all<Size>(
                                              Size(
                                                100,
                                                40,
                                              ), // Set the width and height of the button
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.grey),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          onPressed: () {
                                            // Close the dialog
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        'Log out',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.indigo),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
