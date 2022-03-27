import 'package:flutter/material.dart';

class JongRo extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _JongRo();
}

class _JongRo extends State<JongRo> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(5.0),
              child: Row(children: [
                Expanded(
                    flex: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('Assets/Image/title.PNG'),
                          fit: BoxFit.cover,
                        )
                      ),
                    ),
                ),
                Spacer(flex: 1),
                Expanded(
                  flex: 14,
                  child: Container(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text("자전거길",
                            style: TextStyle(
                                fontSize: 17.0, fontWeight: FontWeight.bold)),
                        Row(
                          children: <Widget>[
                            Text(
                              '주소',
                              style: TextStyle(fontSize: 14),
                            )
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              SizedBox(
                                width: 30,
                                height: 30,
                                child: RaisedButton(
                                    onPressed: null,
                                    child: Text("a")),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ]
              ),
            ),
          );
        }
      )
    );
  }
}