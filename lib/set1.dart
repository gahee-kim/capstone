import 'package:flutter/material.dart';

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Size get preferredSize => Size(0.0, 0.0);
}

class Set1 extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: EmptyAppBar(
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RaisedButton(
                child: Text('공지사항',
                  style: TextStyle(
                      fontSize: 30.0),),
                onPressed: (){
                  Navigator.pushNamed(context, '/b');
                }),

            RaisedButton(
              child: Text('버전정보',
                style: TextStyle(
                    fontSize: 30.0),),
              onPressed: (){
    Navigator.pushNamed(context, '/c');
    }),

    RaisedButton(
    child: Text('알림',
      style: TextStyle(
          fontSize: 30.0),),
    onPressed: () {
      Navigator.pushNamed(context, '/d');
    }),

    RaisedButton(
    child: Text('친구',
      style: TextStyle(
          fontSize: 30.0),),
    onPressed: () {
      Navigator.pushNamed(context, '/e');
    }),

    RaisedButton(
        child: Text('개인정보',
          style: TextStyle(
              fontSize: 30.0),),
        onPressed: (){
          Navigator.pushNamed(context, '/f');
        })
          ],
        ),
      ),
    );
  }
}
