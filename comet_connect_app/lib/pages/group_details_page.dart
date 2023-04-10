// ignore_for_file: non_constant_identifier_names, unnecessary_string_interpolations

import 'package:comet_connect_app/pages/homepage.dart';
import 'package:flutter/material.dart';

class GroupDetailsPage extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String session_id;
  final List<dynamic> users;

  const GroupDetailsPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.session_id,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$groupName'),
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
              '\tGroup ID: $groupId',
              style: const TextStyle(fontSize: 16.0),
            ),

            // Group Name
            const SizedBox(height: 16.0),
            SelectableText(
              '\tGroup Name: $groupName',
              style: const TextStyle(fontSize: 16.0),
            ),

            // Session ID
            const SizedBox(height: 16.0),
            SelectableText(
              '\tSession ID: $session_id',
              style: const TextStyle(fontSize: 16.0),
            ),
            const Divider(),

            // Current Users in Group Selected
            const SizedBox(height: 16.0),
            const Text(
              'Current Users in the Group:',
              style: TextStyle(fontSize: 20.0),
            ),

            // Display users and their calendar oid's in current group selected
            const SizedBox(height: 16.0),
            SelectableText(
              '${users.map((user) => '- Username: ${user['username']}\n\t\t\t\t\t\t\tName: ${user['first_name']} ${user['last_name']}\n\t\t\t\t\t\t\tCalendar OID: ${user['calendar']}').join('\n\t\n')}',
              style: const TextStyle(fontSize: 16.0),
            ),

            // Display
          ],
        ),
      ),
    );
  }
}
