// ignore_for_file: prefer_const_constructors

import 'package:comet_connect_app/pages/homepage.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  // TODO: change to map instead of parallel lists
  final List<String> _faqs = [
    'How do I create an account?',
    'How do I reset my password?',
    'How do I join a group?',
    'How do I leave a group?',
    'How do I create a new group?',
    'How do I delete a group?',
  ];

  final List<String> _faqAnswers = [
    'To create an account, go to the login page and clink of the "Sign Up" button. You will be redirected to the signup page to enter your account details.',
    'To reset your password, click on the "CHANGE PASSWORD" button in the sidebar menu. You will be redirected to another page to reset your password.',
    'To join a group, go to the group page and click the "Join" button.',
    'To leave a group, go to the group page and click the "Leave" button.',
    'To create a new group, go to the groups page and click the "Create Group" button. Then enter the information that it asks for. ',
    'To delete a group, go to the group page and click the "Delete Group" button.',
  ];

  HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Page'),
        backgroundColor: UTD_color_primary,
      ),
      body: ListView.builder(
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          final answer = _faqAnswers[index];
          return Card(
            child: ListTile(
              title: Text(faq),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(faq),
                    content: Text(answer),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
