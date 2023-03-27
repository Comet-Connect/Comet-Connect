// ignore_for_file: library_private_types_in_public_api

import 'package:comet_connect_app/pages/homepage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'login.dart';

final emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

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
  String auth = "chatappauthkey231r4";
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sign up',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Sign Up'),
          ),
          // Main Body of Signup
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // first name field
                  const SizedBox(height: 20.0),
                  const Text(
                    'First Name',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your first name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // last name field
                  const Text(
                    'Last Name',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your last name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // email field
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20.0),

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

                  // password field
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

                  // signup button
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        signup(
                            context,
                            _usernameController.text,
                            _passwordController.text,
                            _firstNameController.text,
                            _lastNameController.text,
                            _emailController.text);
                      },
                      child: const Text('Sign Up'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

signup(context, String username, String password, String firstName,
    String lastName, String email) {
  String auth = "chatappauthkey231r4";
  bool isGoodInput =
      checkInputFields(context, username, password, firstName, lastName, email);
  if (!isGoodInput) {
    return;
  }

  WebSocketChannel? channel;
  try {
    // Create connection.
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.1.71:3000'),
    );
  } catch (e) {
    print("""Error on connecting to websocket: (login.dart)
            ${e.toString()}""");
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
  String signUpData =
      '{"auth":"$auth","cmd":"signup","email":"$email","username":"$username","password":"$password","first_name":"$firstName","last_name":"$lastName"}';

  // Send data to Node.js
  channel?.sink.add(signUpData);

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
        prefs.setString("mailOrUsername", username);
        // Return user to home page if successful
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
        // Call Welcome Screen Display
        showWelcomeDialog(context);
        print("Signup Successful!!!!!");
      } else {
        // TODO: update for signup instead of login
        // Throw pop up if User Login was unsuccessful
        channel?.sink.close();
        if (responseData["status"] == "existing_username") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Signup Failed'),
                content: const Text('Username already in use'),
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
        } else if (responseData["status"] == "existing_email") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Signup Failed'),
                content: const Text('Email already in use'),
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
        } else if (responseData["status"] == "signup_error") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Signup Failed'),
                content: const Text("""Error occured while trying to sign up.\n
                                          Please try again later."""),
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
      }
    },
    onError: (error) {
      print("""Error on connecting to websocket: (login.dart)
            ${error.toString()}""");
    },
    onDone: () {
      print("Websocket is done!");
    },
  );
}

bool checkInputFields(context, String username, String password,
    String firstName, String lastName, String email) {
  bool isGoodInput = true;
  if (username.isEmpty ||
      password.isEmpty ||
      firstName.isEmpty ||
      lastName.isEmpty ||
      email.isEmpty) {
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
  if (username.contains(" ")) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bad Username'),
          content: const Text(
              """Username can not contain a space.\nConsider using an underscore."""),
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
  if (!emailRegex.hasMatch(email)) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bad Email'),
          content: const Text("Please enter a valid email"),
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
