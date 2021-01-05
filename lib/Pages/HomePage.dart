import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AccountSettingsPage.dart';
import 'ChattingPage.dart';

class HomeScreen extends StatefulWidget {
  @override
  State createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  String currentUserId;

  User currentUser = FirebaseAuth.instance.currentUser;

  Future<bool> onBackPress() {
    Navigator.pop(context, exit(0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage()));
              })
        ],
        title: Container(
          margin: EdgeInsets.only(bottom: 4.0),
          child: TextFormField(
            style: TextStyle(color: Colors.white),
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search here...',
              hintStyle: TextStyle(
                color: Colors.white,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              filled: true,
              prefixIcon: Icon(
                Icons.person_pin,
                color: Colors.white,
                size: 30.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onPressed: searchController.clear,
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: WillPopScope(
        onWillPop: onBackPress,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.lightBlueAccent),
                ),
              );
            } else {
              return ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemBuilder: (context, int index) {
                  if (snapshot.data.docs[index]['id'] == currentUser.uid) {
                    return Container();
                  } else {
                    return ListTile(
                      contentPadding: EdgeInsets.all(5.0),
                      leading: Material(
                        borderRadius: BorderRadius.all(Radius.circular(35.0)),
                        clipBehavior: Clip.hardEdge,
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation(
                                  Colors.lightBlueAccent),
                            ),
                          ),
                          imageUrl: snapshot.data.docs[index]['photoUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                snapshot.data.docs[index]['nickName'],
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(
                            snapshot.data.docs[index]['aboutMe'],
                          ),
                        ],
                      ),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                    peerId: snapshot.data.docs[index].id,
                                    peerAvatar: snapshot.data.docs[index]
                                        .data()['photoUrl'],
                                    peerName: snapshot.data.docs[index]
                                        .data()['nickName'],
                                  ))),
                    );
                  }
                },
                itemCount: snapshot.data.documents.length,
              );
            }
          },
        ),
      ),
    );
  }
}
