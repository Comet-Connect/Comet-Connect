import 'dart:convert';

import 'package:comet_connect_app/homepage.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:google_sign_in/google_sign_in.dart';

// login(context, _mail, _pwd) async {
//   String auth = "chatappauthkey231r4";
//   if (_mail.isNotEmpty && _pwd.isNotEmpty) {
//     IOWebSocketChannel channel;
//     try {
//       // Create connection.
//       //channel = IOWebSocketChannel.connect('ws://localhost:51744/$_mail');
      
//       channel = IOWebSocketChannel.connect('ws://localhost:51744/');
      
//       // Data that will be sended to Node.js
//       String signUpData =
//           "{'auth':'$auth','cmd':'login','email':'$_mail','hash':'$_pwd'}";
//       // Send data to Node.js
//       channel.sink.add(signUpData);
//       // listen for data from the server
//       channel.stream.listen((event) async {
//         event = event.replaceAll(RegExp("'"), '"');
//         var loginData = json.decode(event);
//         // Check if the status is succesfull
//         if (loginData["status"] == 'succes') {
//           // Close connection.
//           channel.sink.close();

//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           prefs.setBool('loggedin', true);
//           prefs.setString('mail', _mail);
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
//     } catch (e) {
//       print("Error on connecting to websocket: (login.dart) " + e.toString());
//     }
//   } else {
//     print("Password are not equal");
//   }
// }

void authenticateUser(
  String username,
  String password,
  Function() onSuccess,
  Function(String) onError,
) async {
  try {
    // Connect to MongoDB server
    final db = await mongo.Db.create('mongodb://localhost:57224/my_database');
    await db.open();

    // Query the users collection to find the user with the given username and password
    final user = await db.collection('users').findOne(mongo.where.eq('username', username).eq('password', password));

    // Close the database connection
    await db.close();

    if (user != null) {
      // Authentication successful
      onSuccess();
    } else {
      // Authentication failed
      onError('Invalid username or password');
    }
  } catch (error) {
    // Handle database connection error
    onError(error.toString());
  }
}

