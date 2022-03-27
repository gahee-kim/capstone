import 'package:flutter/material.dart';
import 'friends.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'DatabaseService.dart';

class FriendsList extends StatefulWidget {

  @override
  _FriendsList createState() => _FriendsList();
}

class _FriendsList extends State<FriendsList> {

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  DatabaseService database = DatabaseService();

  currUser() {
    final User? user = _auth.currentUser;
    final uid = user!.uid;
    return uid.toString();
  }
  List<String> names = [];
  List<String> uids = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').doc(currUser()).collection('friends').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          else {
            names.clear();
            uids.clear();
            final users = snapshot.data!.docs;
            for(var user in users){
              var username = user['name'];
              var uid = user['uid'];
              names.add(username.toString());
              uids.add(uid.toString());
            }
              return ListView.builder(
                itemCount: names.length,
                itemBuilder: (context, i){
                  return ListTile(
                    leading: Icon(Icons.account_circle, color: ((uids[i] == currUser() ? Colors.grey : Colors.black)),),
                    title: Text(names[i], style: TextStyle(color: (uids[i] == currUser() ? Colors.grey : Colors.black)),),
                  );
                }
              );
          }
        }
      );
  }
}
