import 'package:flutter/material.dart';
import 'dart:convert';
import 'login.dart';
import 'package:comet_connect_app/config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:comet_connect_app/pages/login_or_signup.dart';

class ResetPage extends StatefulWidget {
  const ResetPage({Key? key}) : super(key: key);
  
  @override
  _ResetPageState createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage>{
  
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset'),
        // Return to main login screen
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
       // Main Body of Signup
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: []
          )
        )
      )
    );
  } //Widget
}
