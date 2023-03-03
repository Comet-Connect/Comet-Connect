import './login_or_signup.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

username() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mail = prefs.getString('mail');

  return Text("Mail is: $mail");
}

// class MyHomePage extends StatelessWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     logOut() async {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       // Set loggedIn back to false
//       prefs.setBool('loggedin', false);
//       // Delete mail user.
//       prefs.remove('mail');

//       // Navigate to homepage.
//       Navigator.push(
//         context,
//         PageRouteBuilder(
//           pageBuilder: (c, a1, a2) => const LoginOrSignup(),
//           transitionsBuilder: (c, anim, a2, child) =>
//               FadeTransition(opacity: anim, child: child),
//           transitionDuration: const Duration(milliseconds: 200),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text("You have succesfully logged in!"),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Center(
//             child: FutureBuilder<Widget>(
//               future: username(),
//               builder: (BuildContext context, snapshot) {
//                 if (snapshot.hasData) {
//                   return snapshot.data!;
//                 } else {
//                   return const Text("Mail is: undefined");
//                 }
//               },
//             ),
//           ),
//           Center(
//             child: MaterialButton(
//               child: const Text("Logout"),
//               onPressed: () => logOut(),
//             ),
//           ),
//         ],
//       ),
//     );

//   }
// }

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Page',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Homepage'),
        ),
        
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Welcome back, Comet!',
                style: TextStyle(fontSize: 24.0),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'This is your home page.',
                style: TextStyle(fontSize: 18.0),
              ),
              // const SizedBox(height: 16.0),
              // ElevatedButton(
              //   onPressed: () {
              //     // TODO: Implement button action
                  
              //   },
              //   child: const Text('Learn more'),
              //),
            ],
          ),
        ),
      ),
    );
  }
}
