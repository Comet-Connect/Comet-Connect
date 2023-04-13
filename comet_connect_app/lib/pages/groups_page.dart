// ignore_for_file: avoid_print, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'package:comet_connect_app/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../auth/login.dart';
import '../classes/group_class.dart';
import 'create_groups.dart';
import 'group_details_page.dart';
import 'package:comet_connect_app/config.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final _searchController = TextEditingController();
  List<Group> _groups = [];
  Group? _hoveredGroup;
  WebSocketChannel? _channel;
  String? _newestGroupOid;

  // Initial State
  @override
  void initState() {
    super.initState();
    _connectToWebSocketServer();
    _getGroups();
  }

  // Closing the WSS
  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  // Startup WSS
  void _connectToWebSocketServer() async {
    Map config = await getServerConfigFile();

    // Connecting to WS Server
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://${config["host"]}:${config["port"]}'),
    );
    // Check if current logged in user is not null
    if (current_loggedin_user != null) {
      _getGroups();
    }

    // Listen to the channel Stream
    _channel?.stream.listen((event) {
      final data = json.decode(event);
      print('Received data from server: \n\t$event\n');

      if (data['cmd'] == 'get_groups') {
        final groupsData = data['data'];
        print('Received groups data: $groupsData');

        final groups = groupsData
            .map<Group>((groupData) => Group(
                  oid: groupData['id'],
                  name: groupData['name'],
                  description: groupData['description'],
                  sessionId: groupData['session_id'],
                  users: groupData['users'],
                ))
            .toList();

        setState(() {
          _groups = groups;
        });
      } else if (data['cmd'] == 'get_group') {
        final groupData = data['group'];
        if (groupData != null) {
          final group = Group(
            oid: groupData['id'],
            name: groupData['name'],
            description: groupData['description'],
            sessionId: groupData['session_id'],
            users: groupData['users'],
          );
          // Navigate to Group Details page
          Navigator.pushNamed(context, '/group/${group.oid}');
        } else {
          final status = data['status'];
          // Show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to get group: $status')),
          );
        }
      } else if (data['cmd'] == 'join_group' && data['status'] == 'success') {
        setState(() {
          _newestGroupOid = data['group_id'];
          _getGroups();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined group!'),
          ),
        );

        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            _newestGroupOid = '';
            _getGroups();
          });
        });
      } else if (data['cmd'] == 'join_group' &&
          data['status'] == 'already_joined') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Join Group Failed'),
                content: const Text('You are already in this group'),
                actions: <Widget>[
                  TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ],
              );
            });
      } else if (data['cmd'] == 'join_group' &&
          data['status'] == 'group_not_found') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Join Group Failed'),
                content: const Text('Group does not exist'),
                actions: <Widget>[
                  TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ],
              );
            });
      }
    });
  }

  // Success
  // Retrieves List of Groups from mongodb
  void _getGroups() {
    final userId = current_loggedin_user_oid;
    _channel?.sink.add(json.encode({
      'cmd': 'get_groups',
      'auth': 'chatappauthkey231r4',
      'oid': userId,
    }));
  }

  // TODO
  // void _getGroup(String oid) {
  //   _channel?.sink.add(json.encode({
  //     'cmd': 'get_group',
  //     'auth': 'chatappauthkey231r4',
  //     'oid': oid,
  //   }));
  // }

  //Success
  // Functionality for Search Bar to filter Groups
  void _searchGroups(String searchText) {
    if (searchText.isEmpty) {
      _getGroups();
    } else {
      List<Group> filteredGroups = _groups
          .where((group) =>
              group.name.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
      setState(() {
        _groups = filteredGroups;
      });
    }
  }

  // Success
  // Functionality for joining group using sessionId
  void _joinGroup(String sessionId) {
    _channel?.sink.add(json.encode({
      'cmd': 'join_group',
      'auth': 'chatappauthkey231r4',
      'session_id': sessionId,
      'user_id': current_loggedin_user_oid,
    }));
  }

  // Success
  void _leaveGroup(String oid) {
    _channel?.sink.add(json.encode({
      'cmd': 'leave_group',
      'auth': 'chatappauthkey231r4',
      '_id': oid,
      'user_oid': current_loggedin_user_oid,
    }));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Successfully left group!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _getGroups();
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Success
  // Calls out details page
  void navigateToGroupDetailsPage(Group selectedGroup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailsPage(
          groupId: selectedGroup.oid,
          groupName: selectedGroup.name,
          session_id: selectedGroup.sessionId,
          users: selectedGroup.users,
        ),
        settings: RouteSettings(
          name: '/group/${selectedGroup.name}',
        ),
      ),
    );
  }

  // Building the Groups Page itself
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        backgroundColor: UTD_color_primary,
      ),
      body: Padding(
        // Padding around all edges
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nav bar row for groups page
            Row(
              children: [
                // Search Bar
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        _searchGroups(value);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ],
            ), // End of Nav Bar Row
            Expanded(
              child: _buildListView(),
            ),
          ],
        ),
      ),
      // Footer
      persistentFooterButtons: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Create Group Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to the create group screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateGroupScreen(),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey[800]!),
                ),
                child: const Text('Create Group'),
              ),

              // Join Group Button
              const SizedBox(width: 40),
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
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.grey[800]!),
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
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey[800]!),
                ),
                child: const Text('Join Group'),
              ),
            ], //end of row line for buttons
          ),
        ),
      ],
    );
  }

  // Filtering List View with hovering highlight
  Widget _buildListView() {
    List<Group> _filteredGroups = _groups
        .where((group) => group.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
        .toList();

    if (_filteredGroups.isEmpty) {
      return const Center(
        child: Text('You are not in any groups.\n Create or Join a Group!'),
      );
    }

    return ListView.builder(
      itemCount: _filteredGroups.length,
      itemBuilder: (BuildContext context, int index) {
        final group = _filteredGroups[index];

        return MouseRegion(
          onEnter: (_) {
            setState(() {
              _hoveredGroup = group;
            });
          },
          onExit: (_) {
            setState(() {
              _hoveredGroup = null;
            });
          },
          child: Card(
            color: _hoveredGroup == group ? Colors.grey[300] : Colors.white,
            child: ListTile(
              leading: const Icon(Icons.group),
              title: Text(group.name),
              subtitle: Text(group.description),
              shape: (group.oid == _newestGroupOid)
                  ? Border(
                      top: BorderSide(color: UTD_color_secondary, width: 2.0),
                      left: BorderSide(color: UTD_color_secondary, width: 2.0),
                      bottom:
                          BorderSide(color: UTD_color_secondary, width: 2.0),
                      right: BorderSide(color: UTD_color_secondary, width: 2.0))
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/edit-group/${group.name}',
                        arguments: {'group': group},
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Leave Group'),
                          content: const Text(
                              'Are you sure you want to leave this group?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _leaveGroup(group.oid);
                              },
                              child: const Text('Leave'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              // Call Details Page
              onTap: () {
                navigateToGroupDetailsPage(group);
              },
            ),
          ),
        );
      },
    );
  }
}
