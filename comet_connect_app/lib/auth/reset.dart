// ignore_for_file: library_private_types_in_public_api
import 'package:comet_connect_app/auth/login.dart';
import 'package:comet_connect_app/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:comet_connect_app/config.dart';
import 'dart:convert';

class ResetPage extends StatefulWidget {
  const ResetPage({Key? key}) : super(key: key);

  @override
  _ResetPageState createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  final _oldPasswordController = TextEditingController(); // User Password
  final _passwordNewController = TextEditingController(); // User New Password
  final _passwordCfController =
      TextEditingController(); // User Confirm New Password

  bool _obscurePassword = true; // Show password feature
  final _auth = "chatappauthkey231r4"; // Authentication Key

  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _connectToWebSocketServer();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  void _connectToWebSocketServer() async {
    Map config = await getServerConfigFile();
    if (config.containsKey("is_server") && config["is_server"] == "1") {
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://${config["host"]}/ws'),
      );
    } else {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://${config["host"]}:${config["port"]}'),
      );
    }
    print("Connecting to groups WSS");

    _channel?.stream.listen((event) {
      final data = json.decode(event);
      print('Received data from server: \n\t$data\n');

      if (data['cmd'] == 'change_pw' && data['status'] == 'password_changed') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Password updated.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const MyHomePage()));
                      },
                      child: const Text('OK'))
                ],
              );
            });
      } else if (data['cmd'] == 'change_pw' &&
          data['status'] == 'invalid_password') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('New password same as old password.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'))
                ],
              );
            });
      }
    });
  }

  void _reset(String password, String newPassword, String cfPassword) {
    bool allFieldsFilled =
        _checkInputsFilled(password, newPassword, cfPassword);
    if (!allFieldsFilled) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Please fill out all fields.'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'))
              ],
            );
          });
      return;
    }

    bool matchingPasswords = _checkMatchingPasswords(newPassword, cfPassword);
    if (!matchingPasswords) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('New passwords do not match.'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'))
              ],
            );
          });
      return;
    }

    Map passwordInfo = {
      'cmd': 'change_pw',
      'auth': _auth,
      'user_id': current_loggedin_user_oid,
      'old_password': password,
      'new_password': newPassword,
    };
    _channel!.sink.add(json.encode(passwordInfo));
  }

  bool _checkInputsFilled(
      String password, String newPassword, String cfPassword) {
    if (password.isEmpty || newPassword.isEmpty || cfPassword.isEmpty) {
      return false;
    }

    return true;
  }

  bool _checkMatchingPasswords(String password, String confirmPassword) {
    if (password != confirmPassword) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Reset Password'),
          // Return to main login screen
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: UTD_color_primary,
        ),
        // Main Body of Signup
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // old password field
                      const Text(
                        'Current Password',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextField(
                        obscureText: _obscurePassword,
                        controller: _oldPasswordController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter your password',
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // toggle hidden password
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
                      // new password field
                      const Text(
                        'New Password',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextField(
                        obscureText: _obscurePassword,
                        controller: _passwordNewController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter your new password',
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // toggle hidden password
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
                      // confirm password field
                      const Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextField(
                        obscureText: _obscurePassword,
                        controller: _passwordCfController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Confirm your new password',
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // toggle hidden password
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

                      //reset button
                      const SizedBox(height: 20.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _reset(
                                _oldPasswordController.text,
                                _passwordNewController.text,
                                _passwordCfController.text);
                          },
                          child: const Text('Reset'),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.grey[800]!)),
                        ),
                      ),
                    ]))));
  } //Widget
}
