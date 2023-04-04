import 'package:flutter/material.dart';

class GroupDetailsPage extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String session_id;
  final List<dynamic> users;

  const GroupDetailsPage({
    required this.groupId,
    required this.groupName,
    required this.session_id,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    String usersString = users.join('\n\t\t- ');

    return Scaffold(
      appBar: AppBar(
        title: Text('$groupName'),
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
            const SizedBox(height: 16.0),
            SelectableText(
              '\tGroup ID: $groupId',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            SelectableText(
              '\tGroup Name: $groupName',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            SelectableText(
              '\tSession ID: $session_id',
              style: const TextStyle(fontSize: 16.0),
            ),
            const Divider(),
            const SizedBox(height: 16.0),
            const Text(
              'Current Users in the Group:',
              style: TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 16.0),
            SelectableText(
              '${users.map((user) => '- Username: ${user['username']}\n\t\t\t\t\t\t\tName: ${user['first_name']} ${user['last_name']}').join('\n\t\n')}',
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
