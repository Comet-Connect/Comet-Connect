// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:comet_connect_app/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../auth/login.dart';
import 'groups_page.dart';
import 'package:comet_connect_app/config.dart';

/// CreateGroupScreen Class
///
/// This is the Create Group form to create a group for the Comet Connect App
/// Contains:
///    - Group Data (group schema on MongoDB)
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();

  String _groupName = '';
  String _groupDescription = '';

  List<String> _members = [];

  TextEditingController _memberController = TextEditingController();

  WebSocketChannel? channel;

  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    _connectToWebSocketServer();
  }

  @override
  void dispose() {
    channel?.sink.close();
    _memberController.dispose();
    super.dispose();
  }

  void _connectToWebSocketServer() async {
    Map config = await getServerConfigFile();
    if(config.containsKey("is_server") && config["is_server"]=="1") {
        channel = WebSocketChannel.connect(
          Uri.parse('wss://${config["host"]}/ws'),
         );
    }
      else{
          channel = WebSocketChannel.connect(
          Uri.parse('ws://${config["host"]}:${config["port"]}'),
         );
      }
    print("Connecting to groups WSS");
  }

  void createGroup() {
    if (channel == null) {
      print('WebSocket channel is null');
      return;
    }

    final members = _members.map((m) => m.trim()).toList();
    members
        .add(current_loggedin_user!); // Add current user to the list of members

    final sessionId = Random.secure()
        .nextInt(1000000000)
        .toString(); // Generate random session id

    final groupData = {
      "cmd": "create_group",
      "name": _groupName,
      "users": members,
      "description": _groupDescription,
      "sessionId": sessionId, // Add session id to group data
    };

    try {
      channel!.sink.add(json.encode(groupData));
    } catch (e) {
      print('Failed to send WebSocket message: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create group')),
      );
    }

    // Set up a one-time subscription to listen for the response
    subscription = channel!.stream.listen(
      (event) {
        // Parse the JSON data from the server
        event = event.replaceAll(RegExp("'"), '"');

        // Print received data
        print('Received data from server: \n\t$event');

        var responseData = json.decode(event);

        // Check if the response is for group creation
        //if (responseData["cmd"] == 'create_group') {
        // Check if the group creation was successful
        if (responseData["status"] == 'success') {
          // Close the WebSocket channel and subscription
          channel?.sink.close();
          subscription?.cancel();

          // Show the success dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Group Created'),
                content:
                    const Text('Your group has been created successfully.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      // check if button pressed from homescreen or groups page
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyHomePage()),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GroupsPage()),
                      );
                    },
                  ),
                ],
              );
            },
          );
        } else if (responseData['status'] == 'user_not_found') {
          // Show error message for user not found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('One or more users not found.')),
          );
        } else {
          // Show error message for other errors
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create group.')),
          );
        }
        //}
      },
      onError: (e) {
        print('WebSocket stream error: $e');
        subscription?.cancel();
        subscription = null;
      },
      cancelOnError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        backgroundColor: UTD_color_primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Group Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name for the group';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _groupName = value!;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Group Description',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description for the group';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _groupDescription = value!;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add Members',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 10,
                        children: [
                          ..._members
                              .map((member) => Chip(
                                    label: Text(member),
                                    onDeleted: () {
                                      setState(() {
                                        _members.remove(member);
                                      });
                                    },
                                  ))
                              .toList(),
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              controller: _memberController,
                              decoration: const InputDecoration(
                                hintText: 'Enter member email/username',
                              ),
                              onFieldSubmitted: (value) {
                                setState(() {
                                  _members.add(value);
                                  _memberController.clear();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        createGroup();
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.grey[800]!),
                    ),
                    child: const Text('Create Group'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
