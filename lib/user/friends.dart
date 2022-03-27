import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'userList.dart';
import 'userMap.dart';
import 'friendsList.dart';
import 'package:latlong2/latlong.dart';
import 'DatabaseService.dart';
import 'package:location/location.dart' as loc;
import 'dart:async';

List<String> names = [];
List<LatLng> locs = [];
List<String> uids = [];

class Friend extends StatefulWidget {

  @override
  _Friend createState() => _Friend();
}


class _Friend extends State<Friend> {
  var data = FirebaseFirestore.instance.collection('users').doc().get();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String currUsername = '';
  DatabaseService database = DatabaseService();

  currUser() {
    final User? user = _auth.currentUser;
    final uid = user!.uid;
    return uid.toString();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      names.clear();
      locs.clear();
      uids.clear();
      final users = snapshot.data!.docs;
      for (var user in users) {
        var username = user['name'];
        var uid = user['uid'];
        GeoPoint geoPoint = user['location'];
        locs.add(LatLng(geoPoint.latitude, geoPoint.longitude));
        names.add(username.toString());
        uids.add(uid.toString());
      }
      for (int pos = 0; pos < names.length; pos++) {
        if (uids[pos] == currUser())
          currUsername = names[pos];
      }
      print(currUsername);
      return Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.black,
                icon: Icon(Icons.arrow_back),
              ),
              centerTitle: true,
              elevation: 5.0,
              shadowColor: Colors.black12,
              title: Text('친구찾기', style: TextStyle(color: Colors.black),)
          ),
          body: Column(
            children: <Widget>[
              Container(
                  height: 40,
                  margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: Text('내 친구'),
                      ),
                      Spacer(),
                      Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                onPressed: () {
                                  showModalBottomSheet(context: context,
                                      isScrollControlled: true,
                                      builder: (builder) {
                                        return FractionallySizedBox(
                                          heightFactor: 0.9,
                                          child: Column(
                                            children: <Widget>[
                                              // Align(
                                              //   alignment: Alignment.topRight,
                                              //   child: IconButton(onPressed: () {
                                              //     Navigator.pop(context);
                                              //   }, icon: Icon(Icons.close, size: 30)),
                                              // ),
                                              Expanded(
                                                child: userList(),
                                              )
                                            ],
                                          ),
                                        );
                                      });
                                },
                                icon: Icon(Icons.person_add),
                                color: Colors.black,
                                iconSize: 30,),
                              // IconButton(onPressed: () {
                              //
                              // }, icon: Icon(Icons.search))
                            ],
                          )
                      ),
                    ],
                  )
              ),
              Expanded(child: FriendsList()
              ),
              Divider(
                color: Colors.transparent,
              ),
              Container(
                  height: 70,
                  margin: EdgeInsets.all(20.0),
                  color: Colors.black87,
                  child: Row(
                    children: <Widget>[
                      Spacer(),
                      Container(
                        child: Icon(Icons.share_location, color: Colors.white,),
                      ),
                      Container(
                        child: TextButton(
                          child: Text('친구 위치 확인하기', style: TextStyle(
                              fontSize: 20.0, color: Colors.white),),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => userMap(),
                              ),
                            );
                          },
                        ),
                      ),
                      Spacer(),
                    ],
                  )
              )
            ],
          )
      );
    });
  }
}
