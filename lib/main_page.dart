import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainPage extends StatelessWidget {
  MainPage({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            SizedBox(height: 60),
            SizedBox(
              height: 130,
              width: 130,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage("Assets/Image/title.PNG"),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  primary: Color(0xFFF5F6F9),
                  // textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {},
                child: Row(
                  children: [
                    Icon(Icons.person_outlined, size: 25, color: Colors.orange),
                    SizedBox(width: 20),
                    Expanded(child: Text("프로필 편집", style: TextStyle(color: Colors.black38),))],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  primary: Color(0xFFF5F6F9),
                  // textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {},
                child: Row(
                  children: [
                    Icon(Icons.manage_accounts, size: 25, color: Colors.orange),
                    SizedBox(width: 20),
                    Expanded(child: Text("아이디 변경", style: TextStyle(color: Colors.black38),))],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  primary: Color(0xFFF5F6F9),
                  // textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {},
                child: Row(
                  children: [
                    Icon(Icons.manage_accounts, size: 25, color: Colors.orange),
                    SizedBox(width: 20),
                    Expanded(child: Text("비밀번호 변경", style: TextStyle(color: Colors.black38),))],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  primary: Color(0xFFF5F6F9),
                  // textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 25, color: Colors.orange),
                    SizedBox(width: 20),
                    Expanded(child: Text("로그아웃", style: TextStyle(color: Colors.black38),))],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  primary: Color(0xFFF5F6F9),
                  // textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {},
                child: Row(
                  children: [
                    Icon(Icons.account_box, size: 25, color: Colors.orange),
                    SizedBox(width: 20),
                    Expanded(child: Text("회원 탈퇴", style: TextStyle(color: Colors.black38),))],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*appBar: PreferredSize(preferredSize: Size.fromHeight(35.0),
        child: AppBar(
          centerTitle: true,
          title: Text('내 정보'),
          backgroundColor: Colors.blueGrey,
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0.0,
        ),),*/

/* child: Center(
            child: FlatButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
          child: Text("Logout"),
        )), */
