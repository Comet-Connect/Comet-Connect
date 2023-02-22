import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

import './login.dart';

signUp(context, _mail, _user, _pwd, _cpwd) async {
  // Check if email is valid.
  bool isValid = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(_mail);
  String auth = "chatappauthkey231r4";
  // Check if email is valid
  if (isValid == true) {
    if (_pwd == _cpwd) {
      IOWebSocketChannel channel;
      try {
        // Create connection.
        channel =
            IOWebSocketChannel.connect('ws://localhost:3000/signup$_mail');
      
      // Data that will be sended to Node.js
      String signUpData =
          "{'auth':'$auth','cmd':'signup','email':'$_mail','username':'$_user','hash':'$_cpwd'}";
      // Send data to Node.js
      channel.sink.add(signUpData);
      // listen for data from the server
      channel.stream.listen((event) async {
        event = event.replaceAll(RegExp("'"), '"');
        var signupData = json.decode(event);
        // Check if the status is succesfull
        if (signupData["status"] == 'succes') {
          // Close connection.
          channel.sink.close();
          // Return user to login if succesfull
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        } else {
          channel.sink.close();
          print("Error signing signing up");
        }
      });
      // ignore_for_file: avoid_print
} catch (e) {
        
        print("Error on connecting to websocket: ");
      }

    } else {
      print("Password are not equal");
    }
  } else {
    print("email is false");
  }
}

class Signup extends StatelessWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? _mail;
    String? _user;
    String? _pwd;
    String? _cpwd;

    return Scaffold(
      appBar: AppBar(title: const Text("Signup.")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Mail...',
              ),
              onChanged: (e) => _mail = e,
            ),
          ),
          Center(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Username..',
              ),
              onChanged: (e) => _user = e,
            ),
          ),
          Center(
            child: TextField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
              onChanged: (e) => _pwd = e,
            ),
          ),
          Center(
            child: TextField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Confirm password',
              ),
              onChanged: (e) => _cpwd = e,
            ),
          ),
          Center(
            // child: MaterialButton(
            //   child: const Text("Sign up"),
            //   onPressed: signUp(context, _mail, _user, _pwd, _cpwd),
            // ),
            child: MaterialButton(
              onPressed: signUp(context, _mail, _user, _pwd, _cpwd),
              child: const Text("Sign up"),
            ),
          ),
        ],
      ),
    );
  }
}