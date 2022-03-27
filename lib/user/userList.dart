import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'friends.dart';
import 'DatabaseService.dart';
import 'package:location/location.dart' as loc;
import 'userMap.dart';
import 'dart:async';
import 'package:firestore_search/firestore_search.dart';

List<String> names = [];
List<LatLng> locs = [];
List<String> uids = [];

class userList extends StatefulWidget {

  @override
  _userList createState() => _userList();
}


class _userList extends State<userList> {

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
  void initState() {
    super.initState();
  }

  Future addfriends(String uid, String name, LatLng latlng) async {
    await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Text("친구 추가하시겠습니까?"),
        actions: <Widget>[
          new FlatButton(
              onPressed: () async{
                await _firestore.collection('users').doc(currUser()).collection('friends').doc(uid).set({
                  'location' : GeoPoint(latlng.latitude, latlng.longitude),
                  'name' : name,
                  'uid' : uid
                });
                await _firestore.collection('users').doc(currUser()).collection('friends').doc(currUser()).delete();
                Navigator.of(context).pop();
              },
              child: Text("YES")
          ),
          new FlatButton(
            child: Text("NO"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          names.clear();
          locs.clear();
          uids.clear();
          final users = snapshot.data!.docs;
          for(var user in users){
            var username = user['name'];
            var uid = user['uid'];
            GeoPoint geoPoint = user['location'];
            locs.add(LatLng(geoPoint.latitude, geoPoint.longitude));
            names.add(username.toString());
            uids.add(uid.toString());
          }
          for(int pos=0; pos<names.length; pos++){
            if(uids[pos] == currUser())
              currUsername = names[pos];
          }
          print(currUsername);
          return FirestoreSearchScaffold(
            firestoreCollectionName: 'users',
            searchBy: 'name',
            backButtonColor: Colors.grey,
            appBarBackgroundColor: Colors.black,
            clearSearchButtonColor: Colors.red,
            scaffoldBackgroundColor: Colors.white,
            searchBodyBackgroundColor: Colors.white,
            searchTextColor: Colors.black,
            searchIconColor: Colors.white,
            searchBackgroundColor: Colors.white,
            showSearchIcon: true,
            appBarTitle: '이메일 검색',
            scaffoldBody: Column(
              children: [
                    Expanded(
                                child: ListView.builder(
                                  itemCount: names.length,
                                  itemBuilder: (context, i){
                                    return ListTile(
                                      leading: Icon(Icons.account_circle),
                                      title: Text(names[i]),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          IconButton(
                                            onPressed: () async{
                                              if (currUsername == names[i]){

                                              }
                                              else {
                                                addfriends(uids[i], names[i], locs[i]);
                                              }
                                            },
                                            icon: Icon(Icons.add, color: (currUsername == names[i] ? Colors.white : Colors.grey),)
                                          )
                                        ],
                                      ),
                                    );
                                  }
                              )
                    )
              ],
            ),
            dataListFromSnapshot: DataModel().dataListFromSnapshot,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final List<DataModel>? dataList = snapshot.data;
                if (dataList!.isEmpty) {
                  return const Center(
                    child: Text('결과 없음'),
                  );
                }
                return ListView.builder(
                    itemCount: dataList.length,
                    itemBuilder: (context, index) {
                      final DataModel data = dataList[index];
                      return ListTile(
                        leading: Icon(Icons.account_circle),
                        title: Text(
                          ('${data.name}'),
                          style: TextStyle(color: Colors.black87, fontSize: 16),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                                onPressed: () async{
                                  if(currUsername == dataList[index].name.toString()){

                                  }
                                  else {
                                    for(int j=0; j<names.length; j++){
                                      if(dataList[index].name.toString() == names[j]){
                                        addfriends(uids[j], names[j], locs[j]);
                                      }
                                    }
                                  }
                                },
                                icon: Icon(Icons.add, color: (currUsername == '${data.name}' ? Colors.white : Colors.grey),)
                            )
                          ],
                        ),
                      );
                    });
              }

              if (snapshot.connectionState == ConnectionState.done) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('결과 없음'),
                  );
                }
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        }
    );
  }
}

class DataModel {
  final String? name;

  DataModel({this.name});

  //Create a method to convert QuerySnapshot from Cloud Firestore to a list of objects of this DataModel
  //This function in essential to the working of FirestoreSearchScaffold

  List<DataModel> dataListFromSnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((snapshot) {
      final Map<String, dynamic> dataMap =
      snapshot.data() as Map<String, dynamic>;

      return DataModel(
          name: dataMap['name']);
    }).toList();
  }
}