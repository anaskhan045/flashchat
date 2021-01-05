import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'HomePage.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.lightBlueAccent.shade100,
        title: Text(
          'Account Setting',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24.0),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomeScreen())),
              child: Text(
                'Done',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0),
              ))
        ],
        centerTitle: true,
      ),
      body: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String id = '';
  String nickName = '';
  String photoUrl = '';
  String aboutMe = '';
  SharedPreferences preferences;
  TextEditingController nameController;
  TextEditingController aboutMeController;
  File imageFile;
  bool isLoading = false;
  final User firebaseUser = FirebaseAuth.instance.currentUser;
  Reference storageReference;
  Reference ref = FirebaseStorage.instance.ref();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    readDataFromLocal();
  }

  Future<dynamic> uploadFileAndSaveChanges() async {
    try {
      storageReference = ref.child("images/$id");
      await storageReference.putFile(imageFile);

      photoUrl = await storageReference.getDownloadURL();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'WARNING!',
            style: TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
          content: Text(
              'Your account and all related data will be deleted permanently. Would you like to permanently delete your account?'),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'DELETE',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                deleteUser();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();

    id = preferences.getString('id');
    nickName = preferences.getString('nickName');
    photoUrl = preferences.getString('photoUrl');
    aboutMe = preferences.getString('aboutMe');

    nameController = TextEditingController(text: nickName);
    aboutMeController = TextEditingController(text: aboutMe);
    setState(() {});
  }

  Future<void> deleteUser() async {
    setState(() {
      isLoading = true;
    });
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .delete();
      if (storageReference != null) {
        storageReference.delete();
      }
      GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      GoogleSignInAuthentication signInAuthentication =
          await googleSignInAccount.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: signInAuthentication.accessToken,
          idToken: signInAuthentication.idToken);

      UserCredential result =
          await firebaseUser.reauthenticateWithCredential(credential);

      await result.user.delete();
      await FirebaseAuth.instance.signOut();
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
      setState(() {
        isLoading = true;
      });
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyApp()),
          (Route<dynamic> route) => false);

      Fluttertoast.showToast(
          msg:
              'Your Account is Delete permanently. You can sign in again with your google account as a new user ');
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Stack(
                children: [
                  (imageFile == null)
                      ? (photoUrl != '')
                          ? Material(
                              //already existing image will show here
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation(
                                        Colors.lightBlueAccent),
                                  ),
                                  width: 200.0,
                                  height: 200.0,
                                ),
                                imageUrl: photoUrl,
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(125.0)),
                              clipBehavior: Clip.hardEdge,
                            )
                          : Icon(
                              Icons.account_circle,
                              size: 200.0,
                              color: Colors.grey,
                            )
                      : Material(
                          child: Image.file(
                            imageFile,
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius:
                              BorderRadius.all(Radius.circular(125.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                  Container(
                    padding: EdgeInsets.only(left: 130.0, top: 130.0),
                    child: GestureDetector(
                        onTap: () async {
                          try {
                            final imagePicked = await ImagePicker()
                                .getImage(source: ImageSource.gallery);

                            if (imagePicked != null) {
                              setState(() {
                                imageFile = File(imagePicked.path);
                              });
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Icon(
                          Icons.add_a_photo,
                          size: 50.0,
                          color: Colors.lightBlueAccent.withOpacity(0.5),
                        )),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Divider(thickness: 1.5, color: Colors.black45),
              ),
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(
                  top: 10.0,
                  left: 10.0,
                ),
                child: Text(
                  'NAME',
                  style: TextStyle(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: TextFormField(
                  style: TextStyle(fontSize: 18),
                  controller: nameController,
                  onChanged: (value) {
                    nickName = value;
                  },
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(
                  top: 10.0,
                  left: 10.0,
                ),
                child: Text(
                  'EMAIL',
                  style: TextStyle(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: TextFormField(
                  style: TextStyle(fontSize: 18),
                  enabled: false,
                  controller: TextEditingController(text: firebaseUser.email),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(
                  top: 10.0,
                  left: 10.0,
                ),
                child: Text(
                  'ABOUT',
                  style: TextStyle(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: TextFormField(
                  style: TextStyle(fontSize: 18),
                  controller: aboutMeController,
                  onChanged: (value) {
                    aboutMe = value;
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () async {
                            {
                              if (imageFile != null) {
                                await uploadFileAndSaveChanges();
                                Fluttertoast.showToast(
                                    msg: 'profile photo updated successfully');
                              }
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(firebaseUser.uid)
                                  .update({
                                'nickName': nickName,
                                'photoUrl': photoUrl,
                                'aboutMe': aboutMe,
                              });
                            }
                            await preferences.setString('photoUrl', photoUrl);
                            await preferences.setString('nickName', nickName);
                            await preferences.setString('aboutMe', aboutMe);
                            Fluttertoast.showToast(
                                msg: 'Your profile is updated successfully');
                          },
                          child: Text(
                            'Save changes',
                            style: TextStyle(
                                color: Colors.lightBlueAccent, fontSize: 18.0),
                          )),
                    ),
                    GestureDetector(
                        onTap: _showMyDialog,
                        child: Text(
                          'Delete Account',
                          style: TextStyle(
                              color: Colors.redAccent, fontSize: 18.0),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              isLoading = true;
                            });

                            await FirebaseAuth.instance.signOut();
                            await googleSignIn.disconnect();
                            await googleSignIn.signOut();
                            setState(() {
                              isLoading = false;
                            });
                            Fluttertoast.showToast(
                                msg: 'Your account is logged out');
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => MyApp()),
                                (Route<dynamic> route) => false);
                          },
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                                color: Colors.redAccent, fontSize: 18.0),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
          margin: EdgeInsets.only(top: 20.0),
        ),
      ),
    );
  }
}
