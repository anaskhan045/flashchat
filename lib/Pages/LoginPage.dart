import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashchat/Widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomePage.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool isLoggedIn = false;
  bool isLoading = false;
  User currentUser;
  SharedPreferences preferences;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async {
    this.setState(() {
      isLoggedIn = true;
    });

    preferences = await SharedPreferences.getInstance();

    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
    this.setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            margin: EdgeInsets.symmetric(horizontal: 50.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.lightBlueAccent),
                borderRadius: BorderRadius.circular(100.0)),
            child: ListTile(
              onTap: controlSignIn,
              leading: CircleAvatar(
                child: Image.asset(
                  'assets/images/google.png',
                ),
              ),
              title: Text(
                'Sign In with Google',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(1.0),
            child: isLoading ? circularProgress() : Container(),
          )
        ],
      )),
    );
  }

  Future<Null> controlSignIn() async {
    preferences = await SharedPreferences.getInstance();
    this.setState(() {
      isLoading = true;
    });
    try {
      GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      GoogleSignInAuthentication signInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: signInAuthentication.accessToken,
          idToken: signInAuthentication.idToken);

      final User firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;
      //sign in success
      if (firebaseUser != null) {
        final QuerySnapshot resultQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('id', isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> documentSnapshot = resultQuery.docs;

        if (documentSnapshot.length == 0) //new user set data
        {
          FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .set({
            'nickName': firebaseUser.displayName,
            'photoUrl': firebaseUser.photoURL,
            'id': firebaseUser.uid,
            'aboutMe': 'Hey there! i am using telegram',
            'createdAt': DateTime.now().microsecondsSinceEpoch.toString(),
            'chattingWith': null,
          });

          //write data to local
          currentUser = firebaseUser;
          await preferences.setString('id', currentUser.uid);
          await preferences.setString('nickName', currentUser.displayName);
          await preferences.setString('photoUrl', currentUser.photoURL);
          await preferences.setString(
              'aboutMe', 'Hey there! i am using telegram');

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else //user already exist
        {
          //write data to local
          currentUser = firebaseUser;
          await preferences.setString('id', documentSnapshot[0]['id']);
          await preferences.setString(
              'nickName', documentSnapshot[0]['nickName']);
          await preferences.setString(
              'photoUrl', documentSnapshot[0]['photoUrl']);
          await preferences.setString(
              'aboutMe', documentSnapshot[0]['aboutMe']);
        }
        Fluttertoast.showToast(msg: 'Congratulations! Sign In Successful');
        this.setState(() {
          isLoading = false;
        });
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
      //sign in failed
      else {
        Fluttertoast.showToast(msg: 'Try Again! Sign In Failed');
        this.setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
