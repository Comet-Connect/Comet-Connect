import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:mongo_dart/mongo_dart.dart';

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
    print("Login.dart");
    // Connect to MongoDB server
    const String MONGO_CONN_URL =
        "mongodb+srv://admin:bNGtOFxi3UTcv81W@cometconnect.cuwtjrg.mongodb.net/user_info";
    const String USER_COLLECTION = "users";

    //user = "admin";
    //pass = "bNGtOFxi3UTcv81W "

    var db = await mongo.Db.create(MONGO_CONN_URL);
    await db.open();
    inspect(db);
    
    // Query the users collection to find the user with the given username and password
    var user = await db
        .collection(USER_COLLECTION)
        .findOne(mongo.where.eq('username', username).eq('password', password));

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
    onError("(login.dart)$error");
  }
}