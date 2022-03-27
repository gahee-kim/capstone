import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});
  final CollectionReference Collection = FirebaseFirestore.instance.collection('users');

  Future updateUserData(String name, String useruid) async {
    await Collection.doc(uid).set({
      'name' : name,
      'uid' : useruid
    });
    await Collection.doc(uid).collection('friends').doc(uid).set({
    });
    await Collection.doc(uid).collection('bookmarks').doc(uid).set({
    });
    await Collection.doc(uid).collection('records').doc(uid).set({
    });
  }
}