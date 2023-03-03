import 'dart:convert';
import 'dart:async';
import 'package:comet_connect_app/homepage.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

import './login.dart';

// signUp(context, _mail, _user, _pwd, _cpwd) async {
//   // Check if email is valid.
//   bool isValid = RegExp(
//           r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
//       .hasMatch(_mail);
//   String auth = "chatappauthkey231r4";
//   // Check if email is valid
//   if (isValid == true) {
//     if (_pwd == _cpwd) {
//       IOWebSocketChannel channel;
//       try {
//         // Create connection.
//         channel =
//             IOWebSocketChannel.connect('ws://localhost:3000/signup$_mail');
      
//       // Data that will be sended to Node.js
//       String signUpData =
//           "{'auth':'$auth','cmd':'signup','email':'$_mail','username':'$_user','hash':'$_cpwd'}";
//       // Send data to Node.js
//       channel.sink.add(signUpData);
//       // listen for data from the server
//       channel.stream.listen((event) async {
//         event = event.replaceAll(RegExp("'"), '"');
//         var signupData = json.decode(event);
//         // Check if the status is succesfull
//         if (signupData["status"] == 'succes') {
//           // Close connection.
//           channel.sink.close();
//           // Return user to login if succesfull
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const MyHomePage()),
//           );
//         } else {
//           channel.sink.close();
//           print("Error signing signing up");
//         }
//       });
      
// } catch (e) {
        
//         print("Error on connecting to websocket: ");
//       }

//     } else {
//       print("Password are not equal");
//     }
//   } else {
//     print("email is false");
//   }
// }

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _obscurePassword = true; // Show password feature
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              const Text(
                'Username',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                obscureText: _obscurePassword,
                controller: _passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your password',
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Text(_obscurePassword ? 'Show' : 'Hide'),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Add code to create account here
                    // Navigate to the login page if sign up successful
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyHomePage(),
                      ),
                    );
                  },
                  child: const Text('Sign Up'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}