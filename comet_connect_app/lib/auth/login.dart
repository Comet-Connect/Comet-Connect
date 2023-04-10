// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_interpolation_to_compose_strings, avoid_print, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:comet_connect_app/config.dart';
import '../pages/homepage.dart';

String? current_loggedin_user;
String? current_loggedin_user_oid;

login(context, _mailOrUsername, _pwd) async {
  String auth = "chatappauthkey231r4";
  if (_mailOrUsername.isNotEmpty && _pwd.isNotEmpty) {
    WebSocketChannel? channel;
    try {
      // Create connection.
      Map config = await getServerConfigFile();
      channel = WebSocketChannel.connect(
        Uri.parse('ws://${config["host"]}:${config["port"]}'),
      );
    } catch (e) {
      // Print Error Message if Not able to connect to Mongoose Server
      print("Error on connecting to websocket: (login.dart) " + e.toString());
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Connection Error'),
            content: const Text(
                'Unable to connect to server. Please try again later.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
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
    String loginData =
        '{"auth":"$auth","cmd":"login","email":"$_mailOrUsername","username":"$_mailOrUsername","password":"$_pwd"}';

    // Send data to Node.js
    channel?.sink.add(loginData);

    // Listen for data from the server
    channel?.stream.listen(
      (event) async {
        event = event.replaceAll(RegExp("'"), '"');
        // Print received data
        print('Received data from server: \n\t$event');
        var responseData = json.decode(event);
        // Check if the status is successful
        if (responseData["status"] == 'success') {
          // Close connection.
          channel?.sink.close();

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('loggedin', true);
          prefs.setString("mailOrUsername", _mailOrUsername);
          // Return user to home page if successful
          current_loggedin_user = _mailOrUsername;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
          // Call Welcome Screen Display
          showWelcomeDialog(context);
          print("\tUser [$_mailOrUsername] is logged in!\n");

          current_loggedin_user_oid = responseData["oid"];
          print("\tUser OID: $current_loggedin_user_oid!\n");
        } else {
          // Throw pop up if User Login was unsuccessful
          channel?.sink.close();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Login Failed'),
                content: const Text('Invalid email/username or password.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
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

// Welcome Menu
void showWelcomeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Welcome!'),
        content: const Text('Thank you for logging in!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

// Welcome Menu
void loginWelcomeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Thank you for Signing up!'),
        content: const Text('Please Log in!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
