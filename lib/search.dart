import 'dart:io';
import 'package:cardone1/Folder.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cardone1/usermodel.dart';
import 'package:cardone1/homescreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:exif/exif.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home.dart';

class Search extends StatefulWidget {
  final String data;

  const Search({Key? key, required this.data}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<String> imageUrls = [];
  int _selectedIndex = -1;
//  Widget _body = Container();

  final picker = ImagePicker();
  int count = 0;
  XFile? _image;
  XFile? get image => _image;

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

  // Future<void> pickimagewithdate(BuildContext context) async {
  //   print("hello");
  //   DateTime current = DateTime.now();
  //   DateTime old = DateTime.utc(2023, 01, 23);
  //   final FirebaseFirestore dateupload = FirebaseFirestore.instance;
  //   final picker = ImagePicker();
  //   final List<XFile>? selectedImages = await picker.pickMultiImage();
  //   if (selectedImages != null) {
  //     for (var i = 0; i < selectedImages.length; i++) {
  //       File image = File(selectedImages[i].path);
  //       DateTime cretionDate = image.lastModifiedSync();
  //       if (cretionDate.isAfter(old) && cretionDate.isBefore(current)) {
  //         //String fileName = Path.basename(image!.path);
  //         String imageName =
  //             'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
  //
  //         Reference firebaseStorageRef =
  //             FirebaseStorage.instance.ref().child('${widget.data}/$imageName');
  //         UploadTask uploadTask = firebaseStorageRef.putFile(File(image!.path));
  //         TaskSnapshot taskSnapshot = await uploadTask;
  //         String downloadUrl = await taskSnapshot.ref.getDownloadURL();
  //         Navigator.pop(context);
  //         // return downloadUrl;
  //       }
  //     }
  //   }
  // }

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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(width: 8),
              Text(
                "Uploading Image...",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (_image != null) {
      String fileName = Path.basename(image!.path);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('${widget.data}/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(File(image!.path));
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      Navigator.pop(context);
      _loadImages();
      return downloadUrl;
    } else {
      // handle case where _image is null
      print('Image is null');
      return null;
    }
  }

  User? user = FirebaseAuth.instance.currentUser;
  Usermodel loggedInUser = Usermodel();
  String documentId = '';
  final CollectionReference myCollection =
      FirebaseFirestore.instance.collection('users');

  late DatabaseReference dbref;

  Stream<DocumentSnapshot> getUserStream() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .snapshots();
  }

  void _deleteImage() async {
    var ind = imageUrls[_selectedIndex];

    String imageUrl = "${ind}";

    Uri uri = Uri.parse(imageUrl);
    String imageName = uri.pathSegments.last;

    // print(imageName);

    try {
      await FirebaseStorage.instance.ref("$imageName").delete();
    } catch (e) {
      print(e);
    }

    setState(
      () {
        imageUrls.removeAt(_selectedIndex);
        _selectedIndex = -1;
      },
    );
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
        this.documentId = loggedInUser.uid!;
        _loadImages(); // call _loadImages after setting documentId
      });
    });
  }

  void _loadImages() async {
    Reference ref = FirebaseStorage.instance.ref().child("${widget.data}");

    // List all items in the folder
    ListResult result = await ref.listAll();

    List<String> urls = await Future.wait(
      result.items.map((ref) => ref.getDownloadURL()).toList(),
    );

    setState(() {
      imageUrls = urls;
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
        body: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Stack(
            children: [
              GridView.builder(
                itemCount: imageUrls.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(
                        () {
                          _selectedIndex = index;
                        },
                      );
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: CachedNetworkImage(
                            imageUrl: imageUrls[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _selectedIndex == -1
                  ? Container()
                  : SizedBox.expand(
                      child: Container(
                        color: Colors.black,
                        child: Stack(
                          children: [
                            Center(
                              child: CircularProgressIndicator(),
                            ),
                            Center(
                              child: CachedNetworkImage(
                                imageUrl: imageUrls[_selectedIndex],
                                fit: BoxFit.contain,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
        floatingActionButton: _selectedIndex == -1
            ? Row(
                children: [
                  SizedBox(
                    width: 100,
                  ),
                  // FloatingActionButton.extended(
                  //   onPressed: () {
                  //     print('${widget.data}');
                  //     pickimagewithdate(context);
                  //   },
                  //   label: const Text('Select date'),
                  //   icon: const Icon(Icons.camera_alt_rounded),
                  //   backgroundColor: Colors.cyan,
                  // ),
                  SizedBox(
                    width: 10,
                  ),
                  FloatingActionButton.extended(
                    onPressed: () {
                      print('${widget.data}');
                      pickImage(context);
                    },
                    label: const Text('Upload'),
                    icon: const Icon(Icons.camera_alt_rounded),
                    backgroundColor: Colors.cyan,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    backgroundColor: Colors.cyan,
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
                                      "Do You Want To Delete This Photo?",
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
                                              MaterialStateProperty.all<Color>(
                                                  Colors.indigo),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        onPressed: () {
                                          _deleteImage();
                                          Navigator.pop(context);
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
                                              MaterialStateProperty.all<Color>(
                                                  Colors.grey),
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
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 16),
                  FloatingActionButton(
                    backgroundColor: Colors.cyan,
                    onPressed: () {
                      launch(imageUrls[_selectedIndex]);
                    },
                    child: Icon(
                      Icons.download,
                      color: Colors.white,
                    ),
                  ),
                  FloatingActionButton(
                    backgroundColor: Colors.cyan,
                    onPressed: () {
                      setState(() {
                        _selectedIndex = -1;
                      });
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        extendBodyBehindAppBar: true,
      ),
    );
  }
}
