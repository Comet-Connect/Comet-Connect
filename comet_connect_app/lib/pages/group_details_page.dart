import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GroupDetailsPage extends StatelessWidget {
  final String groupId;
  final String groupName; // add groupName parameter
  final String session_id;

  const GroupDetailsPage({
    required this.groupId,
    required this.groupName,
    required this.session_id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$groupName'),
      ),
      body: Center(
        child: SelectableText(
          'Group Details:\n\tgroup oid: $groupId\n\tgroup name: $groupName\n\tsession id: $session_id',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}