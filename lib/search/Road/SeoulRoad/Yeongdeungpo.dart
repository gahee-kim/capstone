import 'package:flutter/material.dart';

class Yeongdeungpo extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _Yeongdeungpo();
}

class _Yeongdeungpo extends State<Yeongdeungpo> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Text("영등포구"),
        ));
  }
}