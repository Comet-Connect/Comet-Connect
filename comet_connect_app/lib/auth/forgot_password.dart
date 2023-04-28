// ignore_for_file: library_private_types_in_public_api, avoid_print
import 'dart:convert';
import 'package:comet_connect_app/pages/login_or_signup.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'package:comet_connect_app/config.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _emailController = TextEditingController(); // User Username
  final _verificationCodeController = TextEditingController();
  final _newPasswordController = TextEditingController(); // User New Password
  final _confirmPasswordController =
      TextEditingController(); // User Confirm New Password

  bool _userFound = false;
  bool _matchingEmailCode = false;
  bool _obscurePassword = true; // Show password feature

  final _auth = "chatappauthkey231r4"; // Authentication Key
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();

    _connectToWebSocketServer();
  }

  // Closing the WSS
  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  void _connectToWebSocketServer() async {
    Map config = await getServerConfigFile();

    // Connecting to WS Server
    if (config.containsKey("is_server") && config["is_server"] == "1") {
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://${config["host"]}/ws'),
      );
    } else {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://${config["host"]}:${config["port"]}'),
      );
    }

    _channel?.stream.listen((event) {
      final data = json.decode(event);
      print('Received data from server: \n\t$event\n');

      if (data['cmd'] == 'forgot_pw' && data['status'] == 'success') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                    'Reset request created.\nCheck your email for a verification code.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _userFound = true;
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'))
                ],
              );
            });
      } else if (data['cmd'] == 'forgot_pw' &&
          data['status'] == 'invalid_email') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Email not found.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'))
                ],
              );
            });
      } else if (data['cmd'] == 'forgot_pw' &&
          data['status'] == 'existing_request') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                    'Existing password reset request found.\nPlease check your email for a code or try again in a few minutes.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'))
                ],
              );
            });
      } else if (data['cmd'] == 'verify_code' && data['status'] == 'success') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Please enter your new password.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _matchingEmailCode = true;
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'))
                ],
              );
            });
      } else if (data['cmd'] == 'verify_code' &&
          data['status'] == 'no_matching_code') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Code does not match.\nPlease try again.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'))
                ],
              );
            });
      } else if (data['cmd'] == 'verify_code' &&
          data['status'] == 'code_expired') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                    'No reset code found.\nPlease send another reset request.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _userFound = false;
                          _verificationCodeController.text = '';
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'))
                ],
              );
            });
      } else if (data['cmd'] == 'change_pw' && data['status'] == 'success') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Successfull reset password.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();

                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const LoginOrSignup(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: const Text('OK'))
                ],
              );
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
          // Return to main login screen
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        // Main Body of Signup
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // username field
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                              enabled: !_userFound,
                              decoration: const InputDecoration(
                                hintText: 'Enter your email',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20.0,
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(10, 60)),
                              // TODO:
                              onPressed: (_userFound)
                                  ? null
                                  : () {
                                      _sendEmailVerificationCode(
                                          _emailController.text);
                                    },
                              child: const Text('Submit'))
                        ],
                      ),
                      // Verification code field
                      const SizedBox(height: 20.0),

                      if (_userFound) ...[
                        const Text(
                          'Enter Verification Code',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Row(children: [
                          Expanded(
                              child: TextField(
                            controller: _verificationCodeController,
                            enabled: !_matchingEmailCode,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter your verification code',
                            ),
                          )),
                          const SizedBox(width: 20.0),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(10, 60)),
                              //  TODO:
                              onPressed: (_matchingEmailCode)
                                  ? null
                                  : () {
                                      _confirmEmailVerificationCode(
                                          _emailController.text,
                                          _verificationCodeController.text);
                                    },
                              child: const Text('Submit'))
                        ]),
                        const SizedBox(height: 20.0),
                      ],

                      if (_matchingEmailCode) ...[
                        // new password field
                        Row(children: [
                          const Text(
                            'New Password',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            child: Text(_obscurePassword ? 'Show' : 'Hide'),
                          ),
                        ]),
                        const SizedBox(height: 10.0),
                        TextField(
                          obscureText: _obscurePassword,
                          controller: _newPasswordController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter your new password',
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Confirm Password',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              child: Text(_obscurePassword ? 'Show' : 'Hide'),
                            ),
                          ],
                          // confirm password field
                        ),
                        const SizedBox(height: 10.0),
                        TextField(
                          obscureText: _obscurePassword,
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Confirm your new password',
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        //reset button
                        const SizedBox(height: 20.0),
                        SizedBox(
                          width: double.infinity,
                          height: 50.0,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_newPasswordController.text !=
                                  _confirmPasswordController.text) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                            'Passwords do not match.'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'))
                                        ],
                                      );
                                    });
                              } else {
                                _updatePassword(
                                    _emailController.text,
                                    _newPasswordController.text,
                                    _confirmPasswordController.text);
                              }
                            },
                            child: const Text('Reset'),
                          ),
                        ),
                      ],
                    ]))));
  } //Widget

  _sendEmailVerificationCode(String email) {
    final resetRequest = {
      "cmd": "forgot_pw",
      "email": email,
      "auth": _auth,
    };

    try {
      _channel!.sink.add(json.encode(resetRequest));
    } catch (e) {
      print("Failed to send to WebSocket: $e");
    }
  }

  _confirmEmailVerificationCode(String email, String verificationCode) {
    final verificationCodeInfoMap = {
      "cmd": "verify_code",
      "email": email,
      "verificationCode": verificationCode,
      "auth": _auth,
    };

    try {
      _channel!.sink.add(json.encode(verificationCodeInfoMap));
    } catch (e) {
      print("Failed to send to WebSocket: $e");
    }
  }

  _updatePassword(String email, String password, String confirmPassword) {
    final passwordInfoMap = {
      "cmd": "change_pw",
      "email": email,
      "password": password,
      "auth": _auth,
    };

    try {
      _channel!.sink.add(json.encode(passwordInfoMap));
    } catch (e) {
      print("Failed to send to WebSocket: $e");
    }
  }
}
