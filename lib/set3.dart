import 'package:flutter/material.dart';

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Size get preferredSize => Size(0.0, 0.0);
}

class Set3 extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: EmptyAppBar(
      ),
      body: Center(
        child: Text('버전'),
      ),
    );
  }
}