// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _usernameOrEmailController = TextEditingController(); // User Username
  final _verificationCodeController = TextEditingController();
  final _passwordNewController = TextEditingController(); // User New Password
  final _passwordCfController =
      TextEditingController(); // User Confirm New Password

  bool _userFound = false;
  bool _matchingEmailCode = false;
  bool _obscurePassword = true; // Show password feature
  String auth = "chatappauthkey231r4"; // Authentication Key

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
                        'Username or Email',
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
                              controller: _usernameOrEmailController,
                              enabled: !_userFound,
                              decoration: const InputDecoration(
                                hintText: 'Enter your username or email',
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
                              onPressed: () {
                                setState(() {
                                  _userFound = true;
                                });
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
                              onPressed: () {
                                setState(() {
                                  _matchingEmailCode = true;
                                });
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
                          controller: _passwordNewController,
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
                          controller: _passwordCfController,
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
                            onPressed: () async {
                              reset(
                                  context,
                                  _usernameOrEmailController.text,
                                  _passwordNewController.text,
                                  _passwordCfController.text);
                            },
                            child: const Text('Reset'),
                          ),
                        ),
                      ],
                    ]))));
  } //Widget

  // TODO:
  _getUserFromUsernameOrEmail(String usernameOrEmail) {}
  _sendEmailVerificationCode(String userOid) {}
  _confirmEmailVerificationCode(String userOid) {}
  _updatePassword(String userOid, String password) {}
}

reset(context, String username, String newPassword, String cfPassword) async {
  String auth = "chatappauthkey231r4";
  bool isGoodInput =
      checkInputFields(context, username, newPassword, cfPassword);
  if (!isGoodInput) {
    return;
  }
}

bool checkInputFields(
    context, String username, String newPassword, String cfPassword) {
  bool isGoodInput = true;
  if (username.isEmpty || newPassword.isEmpty || cfPassword.isEmpty) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Empty Fields'),
          content: const Text("Please fill out all fields."),
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
    isGoodInput = false;
  }

  return isGoodInput;
}
