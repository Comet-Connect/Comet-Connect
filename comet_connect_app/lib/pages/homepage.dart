import 'dart:convert';
import 'package:comet_connect_app/pages/groups_page.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../auth/login.dart';
import 'create_groups.dart';
import 'menu.dart';
import 'login_or_signup.dart';
import 'selectdate.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Home Page',
      home: Scaffold(
        // About
        appBar: AppBar(
          title: const Text('Home Page'),
          backgroundColor: Colors.grey[900],
        ),
        backgroundColor: Colors.grey[300],
        // Create Hambureger Menu
        drawer: const HamburgerMenu(),

        // Main portion of home page
        body: Padding(
          // Padding around all edges
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 800,
                  color: Colors.blueGrey[500],
                  child: const SelectDate(),
                  // child: const Center(
                  //   // TODO: Insert user calendar from DB
                  //   child: Text(
                  //     'Calendar Preview',
                  //     style: TextStyle(fontSize: 24),
                  //   ),
                  // ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        'My Groups',
                        style: TextStyle(fontSize: 24),
                      ),
                      Expanded(
                        // child: ListView(
                        //   children: const [
                        //     GroupTile(name: 'Group 1'),
                        //     GroupTile(name: 'Group 2'),
                        //   ],
                        // ),

                        child: GridView.count(
                          padding: const EdgeInsets.all(20),
                          crossAxisCount: 2,
                          children: const [
                            // GroupTile(name: 'Group 1'),
                            // GroupTile(name: 'Group 2'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to the create group screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateGroupScreen()),
                              );
                            },
                            child: const Text('Create Group'),
                          ),

                          // Join Group Button for homepage
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  String sessionId = "";
                                  return AlertDialog(
                                    title: const Text('Join Group'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          onChanged: (value) {
                                            sessionId = value;
                                          },
                                          decoration: const InputDecoration(
                                            labelText: 'Session ID',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            _joinGroup(sessionId);
                                            Navigator.of(context).pop();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const GroupsPage()),
                                            );
                                          },
                                          child: const Text('Join'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: const Text('Join Group'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          //return MaterialPageRoute(builder: (context) => const MyHomePage());
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MyHomePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        }
        if (settings.name == '/view-calendar') {
          //return MaterialPageRoute(builder: (context) => const SelectDate());
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const SelectDate(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        }
        if (settings.name == '/groups') {
          // return MaterialPageRoute(builder: (context) => const GroupsPage());
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const GroupsPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        }
        if (settings.name == '/login') {
          //return MaterialPageRoute(builder: (context) => Login());
        }
        if (settings.name == '/signout') {
          //return MaterialPageRoute(builder: (context) => const LoginOrSignup());
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginOrSignup(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        }
        return null;
      },
    );
  }

  void _joinGroup(String sessionId) {
    late WebSocketChannel _channel;
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.1.229:3000/$current_loggedin_user_oid/'),
    );

    _channel.sink.add(json.encode({
      'cmd': 'join_group',
      'auth': 'chatappauthkey231r4',
      'session_id': sessionId,
      'user_id': current_loggedin_user_oid,
    }));

    _getGroups(_channel);
  }

  void _getGroups(WebSocketChannel _channel) {
    final userId = current_loggedin_user_oid;
    _channel.sink.add(json.encode({
      'cmd': 'get_groups',
      'auth': 'chatappauthkey231r4',
      'oid': userId,
    }));
  }
}

class GroupTile extends StatelessWidget {
  final String name;

  const GroupTile({super.key, required this.name});

  // List View
  // @override
  // Widget build(BuildContext context) {
  //   return ListTile(
  //     title: Text(name),
  //     trailing: const Icon(Icons.arrow_forward_ios),
  //   );
  // }

  // Grid View
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.blueGrey[100],
        child: SizedBox(
          height: 100,
          child: Center(
            child: Text(
              name,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
