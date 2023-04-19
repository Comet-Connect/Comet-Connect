// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_const_constructors, non_constant_identifier_names

import 'dart:convert';
import 'package:comet_connect_app/pages/groups_page.dart';
import 'package:comet_connect_app/pages/help_page.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../auth/login.dart';
import 'create_groups.dart';
import 'menu.dart';
import 'login_or_signup.dart';
import 'selectdate.dart';
import 'package:comet_connect_app/config.dart';

final UTD_color_primary = Color.fromARGB(255, 1, 78, 11);
final UTD_color_secondary = Color.fromARGB(255, 255, 123, 0);

/// MyHomePage Class
///
/// This is the Homepage of Comet Connect App
/// Contains:
///    - Hamburger Menu  (HamburgerMenu() class)
///    - Preview of Calendar Page (SelectDate() class)
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

        // Set Background Color
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
              // Calendar Preview
              Expanded(
                flex: 10,
                child: Container(
                  height: 800,
                  color: Colors.blueGrey[500],
                  child: GestureDetector(
                    child: const SelectDate(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectDate(),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // My Groups
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

                        // TODO: pull groups from mongo and display
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
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.grey[800]!),
                            ),
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
                                            Navigator.of(context).pop();
                                            _joinGroup(context, sessionId);
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.grey[800]!),
                                          ),
                                          child: const Text('Join'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.grey[800]!),
                            ),
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
        if (settings.name == '/help') {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HelpPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        }
        if (settings.name == '/signout' || settings.name == '/login') {
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

  void _joinGroup(BuildContext context, String sessionId) async {
    late WebSocketChannel _channel;
    Map config = await getServerConfigFile();
    if(config.containsKey("is_server") && config["is_server"]=="1") {
        _channel = WebSocketChannel.connect(
          Uri.parse('wss://${config["host"]}/ws'),
         );
    }
      else{
          _channel = WebSocketChannel.connect(
          Uri.parse('ws://${config["host"]}:${config["port"]}'),
         );
      }

    _channel.sink.add(json.encode({
      'cmd': 'join_group',
      'auth': 'chatappauthkey231r4',
      'session_id': sessionId,
      'user_id': current_loggedin_user_oid,
    }));

    _channel.stream.listen((event) {
      final data = json.decode(event);
      print('Received data from server \n\t$event\n');
      if (data['cmd'] == 'join_group' && data['status'] == 'success') {
        homepageJoinGroupOid = (data['group_id']);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GroupsPage()),
        );
      } else {
        badJoinGroupPopups(context, data);
      }
    });
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
