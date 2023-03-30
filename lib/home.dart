import 'dart:io';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cardone1/profile.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cardone1/usermodel.dart';
import 'package:cardone1/search.dart';
import 'Folder.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final picker = ImagePicker();

  XFile? _image;
  XFile? get image => _image;

  String fid = '';
  String folName = '';

  ValueNotifier<String> myString = ValueNotifier<String>('initialValue');

  Future<void> deleteDocument(String documentId) async {
    try {
      await _firestore.collection('folder').doc(fid).delete();
      print('Document successfully deleted!');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  bool isFidValid() {
    if (fid.endsWith(documentId)) {
      return true;
    }
    return false;
  }

  User? user = FirebaseAuth.instance.currentUser;
  Usermodel loggedInUser = Usermodel();
  String documentId = '';
  final CollectionReference myCollection =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference folderCollection =
      FirebaseFirestore.instance.collection('folder');

  // final CollectionReference folderCollection1 =
  // FirebaseFirestore.instance.collection('folder');

  //final Query query = folderCollection.where('uid', isEqualTo: documentId);
  var data11;
  void getData() async {
    data11 = folderCollection.where("uid", isEqualTo: documentId).get();
  }

  late DatabaseReference dbref;
  late DatabaseReference dbrefFolder;

  Future<QuerySnapshot> getdatafromfolder() async {
    QuerySnapshot querySnapshot = await folderCollection.get();
    return querySnapshot;
  }

  Stream<DocumentSnapshot> getUserStream() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .snapshots();
  }

  void _selectDate(BuildContext context) async {
    final TextStyle style = TextStyle(
      fontSize: 20.0,
    );

    final ThemeData theme = ThemeData(
      textTheme: TextTheme(
        bodyText1: style,
      ),
      primarySwatch: Colors.indigo,
    );

    final DateTime? fromDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: theme,
          child: child!,
        );
      },
    );

    if (fromDate == null) return;

    final DateTime? toDate = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: fromDate,
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: theme,
          child: child!,
        );
      },
    );

    if (toDate == null) return;

    // Do something with the selected date range
    print('Selected date range: $fromDate - $toDate');
  }

  //String a = "";
  late Stream<QuerySnapshot> _folderstream;
  @override
  void initState() {
    super.initState();

    myString.addListener(_onStringChange);

    dbref = FirebaseDatabase.instance.ref().child('users');
    dbrefFolder = FirebaseDatabase.instance.ref().child('folder');
    getData();
    print(data11);
    _folderstream = folderCollection.snapshots();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = Usermodel.fromMap(value.data());
      setState(() {
        this.loggedInUser = Usermodel.fromMap(value.data()!);
        this.documentId = loggedInUser.uid!;
      });
    });
  }

  //final TextEditingController _groupController = TextEditingController();
  final TextEditingController _folderController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _showSearchBar = false;
  @override
  void dispose() {
    _searchController.dispose();
    myString.removeListener(_onStringChange);
    super.dispose();
  }

  Widget createContainer(BuildContext context, DocumentSnapshot document) {
    return GestureDetector(
      onTap: () {
        print('${document['fid']}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Search(data: '${document['fid']}'),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height / 5,
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  'https://picsum.photos/200',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.delete),
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
                                  "Do You Want To Delete This Album?",
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
                                      setState(() {
                                        deleteDocument(fid);
                                        print(fid);
                                      });
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
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  color: Colors.white.withOpacity(0.5),
                ),
                child: Center(
                  child: Text(
                    document['fname'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onStringChange() {}

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
    String fileName = Path.basename(image!.path);
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('$documentId/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(File(image!.path));
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    Navigator.pop(context);
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //final isDialOpen = ValueNotifier(false);
        bool confirmLogout = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                height: 150,
                width: MediaQuery.of(context).size.width / 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "Are you sure want to Exit ?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            fixedSize: MaterialStateProperty.all<Size>(
                              Size(
                                100,
                                40,
                              ), // Set the width and height of the button
                            ),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.indigo),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                          ),
                          child: Text(
                            "Exit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () {
                            // Handle logout
                            exit(0);
                          },
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            fixedSize: MaterialStateProperty.all<Size>(
                              Size(
                                100,
                                40,
                              ), // Set the width and height of the button
                            ),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.grey),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
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
        // Prevent the back button from doing anything
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.cyan,
          title: _showSearchBar
              ? TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.close),
                      color: Colors.white,
                      onPressed: () {
                        setState(
                          () {
                            _showSearchBar = false;
                            _searchController.clear();
                          },
                        );
                      },
                    ),
                  ),
                  autofocus: true,
                )
              : Text(
                  'SendIt',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    fontSize: 21,
                  ),
                ),
          leading: _showSearchBar
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(
                      () {
                        _showSearchBar = false;
                        _searchController.clear();
                      },
                    );
                  },
                )
              : null,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _showSearchBar = true;
                });
              },
            ),
            PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 1,
                  child: Text('Delete Album'),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text('Settings'),
                ),
              ],
              onSelected: (value) {
                if (value == 1) {
                  print('Delete Album');
                  // handle album option
                }
                if (value == 2) {
                  print('Setting');
                  // handle settings option
                }
              },
            )
          ],
        ),
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("folder")
                .where('uid', isEqualTo: documentId)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                //if (fid.endsWith(documentId)) {
                //print('Match');
                QuerySnapshot querySnapshot = snapshot.data;
                // final querySnapshot =
                //     folderCollection.where('uid', isEqualTo: documentId).get();
                //final QuerySnapshot listQueryDocumentSnapshot=async _firestore.collection('folder').where(FieldPath.uid,isEqualTo: documentId).get();
                final List<QueryDocumentSnapshot> listQueryDocumentSnapshot =
                    querySnapshot.docs;
                // print('Hello');

                //document['fname']
                return ListView.builder(
                  itemCount: listQueryDocumentSnapshot.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot document =
                        listQueryDocumentSnapshot[index];

                    return createContainer(context, document);
                  },
                );
              }
              ;
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: Colors.indigo,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          children: [
            SpeedDialChild(
              child: Icon(Icons.create_new_folder_outlined),
              backgroundColor: Colors.grey[100],
              label: 'New Album',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String folderName;
                    return AlertDialog(
                      title: Text('Create Album'),
                      content: TextField(
                        controller: _folderController,
                        decoration: InputDecoration(
                          hintText: 'Enter Album Name',
                        ),
                        onChanged: (value) {
                          folderName = value;
                        },
                      ),
                      actions: [
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: Text('Create'),
                          onPressed: () {
                            setState(
                              () {
                                folName = _folderController.text;
                                fid = folName + "_" + documentId;
                                createFolder();
                              },
                            );
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.upload),
              backgroundColor: Colors.grey[100],
              label: 'Auto Upload',
              onTap: () {},
            ),
          ],
        ),
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: () {
        //     showDialog(
        //       context: context,
        //       builder: (BuildContext context) {
        //         String folderName;
        //         return AlertDialog(
        //           title: Text('Create Album'),
        //           content: TextField(
        //             controller: _folderController,
        //             decoration: InputDecoration(
        //               hintText: 'Enter Album Name',
        //             ),
        //             onChanged: (value) {
        //               folderName = value;
        //             },
        //           ),
        //           actions: [
        //             TextButton(
        //               child: Text('Cancel'),
        //               onPressed: () {
        //                 Navigator.pop(context);
        //               },
        //             ),
        //             TextButton(
        //               child: Text('Create'),
        //               onPressed: () {
        //                 setState(
        //                   () {
        //                     folName = _folderController.text;
        //                     fid = folName + "_" + documentId;
        //                     createFolder();
        //                   },
        //                 );
        //                 //pickImage(context);
        //                 Navigator.pop(context);
        //               },
        //             ),
        //           ],
        //         );
        //       },
        //     );
        //   },
        //   label: const Text(
        //     'New Album',
        //     style: TextStyle(
        //       fontSize: 18,
        //     ),
        //   ),
        //   icon: const Icon(Icons.create_new_folder_outlined),
        //   backgroundColor: Colors.cyan,
        // ),
      ),
    );
  }

  final CollectionReference myCollectionfolder =
      FirebaseFirestore.instance.collection('folder');
  void createFolder() {
    // String folName = _folderController.text;
    // String fid = folName + "_" + documentId;
    if (fid.endsWith(documentId)) {
      print('Match');
    }
    myCollectionfolder.doc(fid).set(
      {
        "fname": folName,
        "uid": documentId,
        "fid": fid,
      },
    );
  }
}
