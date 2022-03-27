import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:map_210521/data/join_or_login.dart';
import 'package:map_210521/helper/login_background.dart';
import 'package:map_210521/login.dart';
import 'login.dart';
import 'config/palette.dart';
import 'package:provider/provider.dart';
import 'map.dart';

class AuthPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomPaint(
            size: size,
            painter: LoginBackground(
                isJoin: Provider.of<JoinOrLogin>(context).isJoin),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _logoImage,
              Stack(
                children: <Widget>[
                  _inputForm(size),
                  _authButton(size),
                  //Container(width: 100, height: 50, color: Colors.black,),
                ],
              ),
              Container(
                height: size.height * 0.05,
              ),
              Consumer<JoinOrLogin>(
                builder: (context, joinOrLogin, child) => GestureDetector(
                    onTap: () {
                      joinOrLogin.toggle();
                    },
                    child: Text(
                      joinOrLogin.isJoin
                          ? "계정이 있으십니까?"
                          : "계정생성",
                      style: TextStyle(
                          color: joinOrLogin.isJoin ? Colors.red : Colors.blue),
                    )),
              ),
              Container(
                height: size.height * 0.05,
              )
            ],
          )
        ],
      ),
    );
  }

  void _register(BuildContext context) async {

    final UserCredential result = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
        email: _emailController.text, password: _passwordController.text);
    final User? user = result.user;

    if (user == null) {
      final snacBar = SnackBar(
        content: Text("Please try again later."),
      );
      Scaffold.of(context).showSnackBar(snacBar);
    }

    // 데이터베이스에 사용자 정보 추가
    await DatabaseService(uid: user!.uid).updateUserData(_emailController.text,
        user.uid.toString(), GeoPoint(0.0, 0.0));

  }

  void _login(BuildContext context) async {
    final UserCredential result = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
        email: _emailController.text, password: _passwordController.text);
    final User? user = result.user;

    if (user == null) {
      final snacBar = SnackBar(
        content: Text("Please try again later."),
      );
      Scaffold.of(context).showSnackBar(snacBar);
    }
  }

  Widget get _logoImage => Expanded(
    child: Padding(
      padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
      child: FittedBox(
        fit: BoxFit.contain,
        child: CircleAvatar(
          backgroundImage: NetworkImage("https://picsum.photos/200"),
        ),
      ),
    ),
  );

  Widget _authButton(Size size) {
    return Positioned(
      left: size.width * 0.15,
      right: size.width * 0.15,
      bottom: 0,
      child: SizedBox(
        height: 50,
        child: Consumer<JoinOrLogin>(
          builder: (context, joinOrLogin, child) => RaisedButton(
            child: Text(
              joinOrLogin.isJoin ? "회원등록" : "로그인",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            color: joinOrLogin.isJoin ? Colors.red : Colors.blue,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                joinOrLogin.isJoin?_register(context):_login(context);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _inputForm(Size size) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.05),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Padding(
          padding:
          const EdgeInsets.only(left: 12.0, right: 12, top: 12, bottom: 32),
          child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        icon: Icon(Icons.account_circle), labelText: "이메일"),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return "Please input correct Email.";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    controller: _passwordController,
                    decoration: InputDecoration(
                        icon: Icon(Icons.vpn_key), labelText: "비밀번호"),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return "Please input correct password.";
                      }
                      return null;
                    },
                  ),
                  Container(
                    height: 8,
                  ),
                  Consumer<JoinOrLogin>(
                    builder: (context, value, child) => Opacity(
                        opacity: value.isJoin ? 0 : 1,
                        child: Text("패스워드 찾기")),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});
  final CollectionReference Collection = FirebaseFirestore.instance.collection('users');

  Future updateUserData(String name, String useruid, GeoPoint location) async {
    await Collection.doc(uid).set({
      'name' : name,
      'uid' : useruid,
      'location' : GeoPoint(curr_lat, curr_lng),
      //'public' : true,
    });
    await Collection.doc(uid).collection('friends').doc(uid).set({
      'location' : GeoPoint(curr_lat, curr_lng),
      'name' : name,
      'uid' : uid
    });
    await Collection.doc(uid).collection('bookmarks').doc(uid).set({
    });
    await Collection.doc(uid).collection('records').doc(uid).set({
      'Origin' : GeoPoint(0, 0),
      'Destination' : GeoPoint(0, 0),
    });
  }
}