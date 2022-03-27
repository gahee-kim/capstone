import 'package:flutter/material.dart';

class GangNam extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _GangNam();
}

class _GangNam extends State<GangNam> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Text("강남구"),
        ));
  }
}