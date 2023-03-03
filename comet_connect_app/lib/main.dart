import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import './login_or_signup.dart';
import './homepage.dart';
import 'login.dart';
import './selectdate.dart.';   

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  //_MyAppState createState() => _MyAppState();
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Widget> autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool('loggedin');
    if (loggedIn == true) {
      return const MyHomePage();
    } else {
      return const LoginOrSignup();    // good
      //return const MyHomePage();     // modify
      //return CalendarPage();         // no   My Calendar Page
      //return const SelectDate();     //good
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: SafeArea(
      child: FutureBuilder<Widget>(
          future: autoLogin(),
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!;
            } else {
              return const LoginOrSignup();
            }
          }),
    )));
  }
}
