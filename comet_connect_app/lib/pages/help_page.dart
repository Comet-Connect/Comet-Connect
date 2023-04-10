import 'package:comet_connect_app/pages/homepage.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  final List<String> _faqs = [
    'How do I create an account?',
    'How do I reset my password?',
    'How do I join a group?',
    'How do I leave a group?',
    'How do I create a new group?',
    'How do I delete a group?',
  ];

  HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
        backgroundColor: UTD_color_primary,
      ),
      body: ListView.builder(
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Card(
            child: ListTile(
              title: Text(faq),
              onTap: () {
                // TODO: Show answer to FAQ
              },
            ),
          );
        },
      ),
    );
  }
}
