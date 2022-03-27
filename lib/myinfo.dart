import 'package:flutter/material.dart';
import 'config/palette.dart';

class Myinfo extends StatefulWidget {
  @override
  _MyinfoState createState() => _MyinfoState();
}

class _MyinfoState extends State<Myinfo> {
  bool isMale = true;
  bool isMyinfo = true;
  bool isRememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: Stack(
        children: [
          Positioned(
          top: 0,
          right: 0,
          left: 0,
          child: Container(
            height: 230,
            child: Container(
              color: Color(0xFF3b5999).withOpacity(.85),
            ),
          ),
          ),
          Positioned(
            top: 120,
            child: Container(
              height: 380,
              padding: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width-40,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                    spreadRadius: 5
                  ),
                ]
              ),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        bool isMyinfo = false;
                      });
                    },
                    child: Column(
                      children: [
                      Text("로그인", style:  TextStyle(
                        fontSize: 16,
                          fontWeight: FontWeight.bold,
                        color:!isMyinfo ? Palette.activeColor : Palette.textColor1),
                      ),
                      if(!isMyinfo)
                      Container(
                        margin: EdgeInsets.only(top: 3),
                        height: 2,
                        width: 55,
                        color: Colors.orange,
                      )
                    ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        bool isMyinfo = true;
                      });
                    },
                    child: Column(children: [
                      Text("회원가입", style:  TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold,
                          color: isMyinfo? Palette.activeColor : Palette.textColor1),
                      ),
                    if(isMyinfo)
                      Container(
                        margin: EdgeInsets.only(top: 3),
                        height: 2,
                        width: 55,
                        color: Colors.orange,
                      )
                    ],),
                  )

                ],)
              ]),

            ),
          )
        ],
      ),
    );
  }
}