import 'dart:convert';

import 'package:comet_connect_app/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../auth/login.dart';
import '../auth/signup.dart';

class LoginOrSignup extends StatefulWidget {
  const LoginOrSignup({Key? key}) : super(key: key);

  @override
  _LoginOrSignup createState() => _LoginOrSignup();
}

class _LoginOrSignup extends State<LoginOrSignup> {
  TextStyle style = const TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  bool _obscurePassword = true; // Show password feature

  final _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  // Google Sign in API
  Future<void> _handleGoogleSignIn() async {
    try {
      await _googleSignIn.signIn();
      // Navigate to the home page if login successful
      const MyHomePage();
    } catch (error) {
      // Handle sign in error
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
        title: 'Sign in',
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: screenWidth / 2,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(width: 1.2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Continue With Google
                    const SizedBox(height: 20.0),
                    ElevatedButton.icon(
                      onPressed: _handleGoogleSignIn,
                      icon: Image.asset(
                        'images/google_logo.png',
                        height: 30.0,
                      ),
                      label: const Text('Continue with Google'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: const BorderSide(color: Colors.black),
                          ),
                        ),
                        // make the button fit in tha box
                        minimumSize: MaterialStateProperty.all<Size>(
                          const Size(double.infinity, 48.0),
                        ),
                      ),
                    ),

                    // or
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("or"),
                      ],
                    ),

                    // Email Section
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

                    // Password Section
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

                    // Show Password Feature
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

                    // Login Button
                    const SizedBox(height: 30.0),
                    SizedBox(
                      width: double.infinity,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Call function from login.dart
                          login(context, _usernameController.text,
                              _passwordController.text);
                          // await authenticateUser(
                          //   _usernameController.text,
                          //   _passwordController.text,
                          //   (token) async {
                          //     // Authentication successful, navigate to home page
                          //     final prefs =
                          //         await SharedPreferences.getInstance();
                          //     await prefs.setString('token', token);
                          //     Navigator.pushReplacement(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => const MyHomePage()),
                          //     );
                          //   },
                          //   (error) {
                          //     // Authentication failed, show error message
                          //     showDialog(
                          //       context: context,
                          //       builder: (BuildContext context) {
                          //         return AlertDialog(
                          //           title: const Text('Error'),
                          //           content: Text(error),
                          //           actions: [
                          //             TextButton(
                          //               onPressed: () => Navigator.pop(context),
                          //               child: const Text('OK'),
                          //             ),
                          //           ],
                          //         );
                          //       },
                          //     );
                          //   },
                          // );
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    // Forgot Password
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    // TODO Create Forgot password functionality
                                    builder: (context) => const SignupPage()));
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ],
                    ),
                    // Container(
                    //   child: const Center(child: Text("Forgot Password?"))
                    // ),
                    // Dont have account option
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignupPage()));
                          },
                          // child: const Text(
                          //     'Sign Up',
                          //     style: TextStyle (
                          //       fontWeight: FontWeight.bold,
                          //     ),
                          // ),
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
