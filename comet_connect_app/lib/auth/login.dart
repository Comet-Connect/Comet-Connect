import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../pages/homepage.dart';

login(context, _mailOrUsername, _pwd) async {
  String auth = "chatappauthkey231r4";
  if (_mailOrUsername.isNotEmpty && _pwd.isNotEmpty) {
    WebSocketChannel? channel;
    try {
      // Create connection.
      channel = WebSocketChannel.connect(
        Uri.parse('ws://192.168.1.229:3000/$_mailOrUsername'),
      );
    } catch (e) {
      print("Error on connecting to websocket: (login.dart) " + e.toString());
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text('Unable to connect to server. Please try again later.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    // Data that will be sent to Node.js
    String loginData = '{"auth":"$auth","cmd":"login","email":"$_mailOrUsername","username":"$_mailOrUsername","password":"$_pwd"}';

    // Send data to Node.js
    channel?.sink.add(loginData);

    // Listen for data from the server
    channel?.stream.listen(
      (event) async {
        event = event.replaceAll(RegExp("'"), '"');
        var responseData = json.decode(event);
        // Check if the status is successful
        if (responseData["status"] == 'success') {
          // Close connection.
          channel?.sink.close();

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('loggedin', true);
          prefs.setString("mailOrUsername", _mailOrUsername);
          // Return user to home page if successful
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
          print("Login Successful!!!!!");
        } else {
          channel?.sink.close();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Login Failed'),
                content: Text('Invalid email/username or password.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      },
      onError: (error) {
        print("Error on connecting to websocket: (login.dart) " +
            error.toString());
      },
      onDone: () {
        print("Websocket is done!");
      },
    );
  } else {
    print("Either email or username and password are required");
  }
}




String _message = 'No data';

Future<void> _getData() async {
  final response =
      await http.get(Uri.parse('http://192.168.1.229:3000/api/data'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    _message = 'Data: $data';
    print(_message);
  } else {
    _message = 'Error fetching data';
    print(_message);
  }
}

Future<void> authenticateUser(String username, String password,
    Function onSuccess, Function(String) onFail) async {
  final loginUrl = 'http://192.168.1.229:3000/api/login';

  try {
    final response = await http.post(Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}));
    print(response.toString());

    if (response.statusCode == 200) {
      final token = json.decode(response.body)['token'];
      onSuccess(token);
    } else {
      onFail('Invalid username or password');
    }
  } catch (e) {
    onFail('Failed to authenticate' + e.toString());
  }
}

// Login endpoint URL
//const String loginUrl = 'http://localhost:3000/api/login';

// Future<void> authenticateUser(
//   String username,
//   String password,
//   Function(String) onSuccess,
//   Function(String) onFail,
// ) async {
//   try {
//     print("Input:  " + username + "  " + password);
//     final response = await http.post(
//       Uri.parse(loginUrl),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'username': username, 'password': password}),
//     );

//     if (response.statusCode == 200) {
//       final token = json.decode(response.body)['token'];
//       onSuccess(token);
//     } else {
//       onFail('Invalid username or password (login.dart)');
//       print(username + " " + password);
//     }
//   } catch (e) {
//     onFail('Failed to authenticate (login.dart)');
//     print(username + " " + password);
//   }
// }
