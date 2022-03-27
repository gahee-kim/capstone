import 'package:flutter/material.dart';

class Mapo extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _Mapo();
}

class _Mapo extends State<Mapo> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Text("마포구"),
        ));
  }
}