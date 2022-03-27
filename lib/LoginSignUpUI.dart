import 'package:flutter/material.dart';
import 'package:map_210521/LoginSignUpScreen.dart';
import 'package:map_210521/data/join_or_login.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'main_page.dart';

class LoginSignUpUI extends StatelessWidget {
  const LoginSignUpUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "login",
      home: Splash(),
    );
  }
}

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, AsyncSnapshot snapshot) {

          if(snapshot.hasData) {
            return MainPage(email: snapshot.data.email); // data가 있으므로 바로 메인 페이지로}
          } else {
            return ChangeNotifierProvider<JoinOrLogin>.value(
                value: JoinOrLogin(),
                child: AuthPage());
          }
        }
    );
  }
}
