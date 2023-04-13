// ignore_for_file: use_build_context_synchronously, unnecessary_string_interpolations, library_private_types_in_public_api

import 'dart:convert';
import 'package:comet_connect_app/config.dart';
import 'package:comet_connect_app/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../auth/login.dart';
import 'meeting_class.dart';

class NewMeetingScreen extends StatefulWidget {
  const NewMeetingScreen({Key? key}) : super(key: key);

  @override
  _NewMeetingScreenState createState() => _NewMeetingScreenState();
}

class _NewMeetingScreenState extends State<NewMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  late DateTime _startTime;
  late DateTime _endTime;

  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _endTime = _startTime.add(const Duration(hours: 1));
    _connectToWebSocketServer();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  void _connectToWebSocketServer() async {
    Map config = await getServerConfigFile();
    if(config.containsKey("is_server") && config["is_server"]=="1") {
        _channel = WebSocketChannel.connect(
          Uri.parse('ws://${config["host"]}/ws'),
         );
    }
      else{
          _channel = WebSocketChannel.connect(
          Uri.parse('ws://${config["host"]}:${config["port"]}'),
         );
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Meeting'),
        backgroundColor: UTD_color_primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  hintText: 'Enter a name for your meeting',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for your meeting';
                  }
                  return null;
                },
              ),

              // Start Time for Meeting
              const SizedBox(height: 16.0),
              const Text('Start Time'),
              TextButton(
                onPressed: () async {
                  final now = DateTime.now();
                  setState(() {
                    _startTime = now;
                  });

                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(now),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _startTime = DateTime(pickedDate.year, pickedDate.month,
                            pickedDate.day, pickedTime.hour, pickedTime.minute);
                      });
                    }
                  }
                },
                child: Text(
                  '${DateFormat('MMM d, yyyy hh:mm a').format(_startTime)}',
                ),
              ),

              // End Time for Meeting
              const SizedBox(height: 16.0),
              const Text('End Time'),
              TextButton(
                onPressed: () async {
                  final now = DateTime.now();
                  setState(() {
                    _endTime = now.add(const Duration(hours: 1));
                  });
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_endTime),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _endTime = DateTime(pickedDate.year, pickedDate.month,
                            pickedDate.day, pickedTime.hour, pickedTime.minute);
                      });
                    }
                  }
                },
                child: Text(
                  '${DateFormat('MMM d, yyyy hh:mm a').format(_endTime)}',
                ),
              ),

              // Create Meeting Button on Create new Meeting Screen
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Send the new meeting data to the backend via WebSocket
                    final newMeeting = Meeting(
                      _eventNameController.text,
                      _startTime,
                      _endTime,
                      Colors.red,
                      false,
                    );
                    final eventData = {
                      'title': newMeeting.eventName,
                      'start': newMeeting.from
                          .toUtc()
                          .toIso8601String(), // Convert to UTC
                      'end': newMeeting.to
                          .toUtc()
                          .toIso8601String(), // Convert to UTC
                    };
                    final userId = current_loggedin_user_oid;
                    _channel?.sink.add(json.encode({
                      'cmd': 'new_meeting',
                      'oid': userId,
                      'event': eventData,
                    }));

                    Navigator.pop(context, newMeeting);
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey[800]!),
                ),
                child: const Text('Create Meeting'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
