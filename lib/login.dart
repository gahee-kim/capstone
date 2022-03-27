import 'package:flutter/material.dart';

class Login extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Text(
                "로그인 성공",
                style: TextStyle(fontSize: 20),
              ))
        ],
      ),
    );
  }
}

