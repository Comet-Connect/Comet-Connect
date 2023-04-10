// ignore_for_file: non_constant_identifier_names, unnecessary_string_interpolations

import 'package:comet_connect_app/pages/homepage.dart';
import 'package:flutter/material.dart';

/// GroupDetailsPage Class
///
/// This is Groups Details Page of a Group for the Comet Connect App
/// Contains:
///    - Group Details
///        - Group ID
///        - Group Name
///        - Session ID
///    - Current Users in Group
///        - Username
///        - Calendar ID
class GroupDetailsPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String session_id;
  final List<dynamic> users;

  const GroupDetailsPage({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.session_id,
    required this.users,
  }) : super(key: key);

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  final List<String> _checkedUsers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.groupName}'),
        backgroundColor: UTD_color_primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Group Details:',
              style: TextStyle(fontSize: 20.0),
            ),

            // Group ID
            const SizedBox(height: 16.0),
            SelectableText(
              '\tGroup ID: ${widget.groupId}',
              style: const TextStyle(fontSize: 16.0),
            ),

            // Group Name
            const SizedBox(height: 16.0),
            SelectableText(
              '\tGroup Name: ${widget.groupName}',
              style: const TextStyle(fontSize: 16.0),
            ),

            // Session ID
            const SizedBox(height: 16.0),
            SelectableText(
              '\tSession ID: ${widget.session_id}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const Divider(
              thickness: 4,
              color: Colors.grey,
            ),

            // Current Users in Group Selected
            const SizedBox(height: 16.0),
            const Text(
              'Current Users in the Group:',
              style: TextStyle(fontSize: 20.0),
            ),

            // Display users and their calendar oid's in current group selected
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.users.length,
              itemBuilder: (BuildContext context, int index) {
                final user = widget.users[index];
                return CheckboxListTile(
                  title: Text(
                    'Username: ${user['username']}\nName: ${user['first_name']} ${user['last_name']}\nCalendar OID: ${user['calendar']}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  value: _checkedUsers.contains(user['username']),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? newValue) {
                    setState(() {
                      if (newValue == true) {
                        _checkedUsers.add(user['username']);
                      } else {
                        _checkedUsers.remove(user['username']);
                      }
                    });
                  },
                );
              },
            ),

            const Divider(thickness: 4, color: Colors.grey),

            // Generate Schedules
            const SizedBox(height: 16.0),
            const Text(
              'Schedules',
              style: TextStyle(fontSize: 20.0),
            ),
            ElevatedButton(
              // Pass in the users that are checked to put in scheduling alg
              onPressed: () {
                // Generate schedules for selected users
                for (final user in _checkedUsers) {
                  // final username = user['username'];
                  // final firstName = user['first_name'];
                  // final lastName = user['last_name'];
                  // final calendarOID = user['calendar'];
                }
                // for (final user in widget.users) {
                // }

                //generate schedules for each user
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey[800]!),
                  fixedSize:
                      MaterialStateProperty.all<Size>(const Size(220, 20))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.schedule, color: Colors.white),
                  SizedBox(width: 10, height: 10),
                  Text(' Generate Schedules',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
