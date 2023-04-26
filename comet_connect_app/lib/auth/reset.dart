
// ignore_for_file: unused_element

import 'package:flutter/material.dart';

class ResetPage extends StatefulWidget {
  const ResetPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ResetPageState createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  final _usernameController = TextEditingController(); // User Username
  final _passwordController = TextEditingController(); // User Password
  final _passwordNewController = TextEditingController(); // User New Password
  final _passwordCfController =
      TextEditingController(); // User Confirm New Password

  bool _obscurePassword = true; // Show password feature
  String auth = "chatappauthkey231r4"; // Authentication Key

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
                      // old password field
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
                          onPressed: () async {
                            reset(
                                context,
                                _usernameController.text,
                                _passwordController.text,
                                _passwordNewController.text,
                                _passwordCfController.text);
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                    ]))));
  } //Widget
}

reset(context, String username, String password, String newPassword,
    String cfPassword) async {
  String auth = "chatappauthkey231r4";
  bool isGoodInput =
      checkInputFields(context, username, password, newPassword, cfPassword);
  if (!isGoodInput) {
    return;
  }
}

bool checkInputFields(context, String username, String password,
    String newPassword, String cfPassword) {
  bool isGoodInput = true;
  if (username.isEmpty ||
      password.isEmpty ||
      newPassword.isEmpty ||
      cfPassword.isEmpty) {
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
  if (newPassword != cfPassword) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error!'),
          content: const Text("Confirmed password does not match with new password."),
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


    
