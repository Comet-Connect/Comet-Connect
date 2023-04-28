// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers, use_build_context_synchronously, library_private_types_in_public_api, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../classes/meeting_class.dart';
import '../config.dart';

class ScheduleMeetingForm extends StatefulWidget {
  final String groupId;
  final String session_id;
  final List<dynamic> checkedUsers;
  final String groupName;

  const ScheduleMeetingForm({
    Key? key,
    required this.groupId,
    required this.session_id,
    required this.checkedUsers,
    required this.groupName,
  }) : super(key: key);

  @override
  _ScheduleMeetingFormState createState() => _ScheduleMeetingFormState();
}

class _ScheduleMeetingFormState extends State<ScheduleMeetingForm> {
  WebSocketChannel? _channel;
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));

  // Initial State
  @override
  void initState() {
    super.initState();
    _connectToWebSocketServer();
  }

  // Closing Connections
  @override
  void dispose() {
    // Close the WebSocket connection when the widget is disposed
    _channel?.sink.close();
    super.dispose();
  }

  // Connect with Backend
  void _connectToWebSocketServer() async {
    try {
      final config = await getServerConfigFile();
      if (config.containsKey('is_server') && config['is_server'] == '1') {
        _channel = WebSocketChannel.connect(
          Uri.parse('wss://${config['host']}/ws'),
        );
      } else {
        _channel = WebSocketChannel.connect(
          Uri.parse('ws://${config['host']}:${config['port']}'),
        );
      }
    } catch (e) {
      print('WebSocket connection failed: $e');
    }
    _channel?.stream.listen(_handleWebSocketMessage);
  }

  void _handleWebSocketMessage(dynamic message) async {
    final data = json.decode(message);

    // Print received data
    print('Received data from server: \n\t$message');
    if (data['cmd'] == 'new_group_meeting' &&
        data['status'] == 'group_not_found') {
      // Meeting scheduled successfully, display success message
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Group not found.'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'))
              ],
            );
          });
    }
    if (data['cmd'] == 'new_group_meeting' &&
        data['status'] == 'calendar_not_found') {
      // Meeting scheduled successfully, display success message
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Calendar not found.'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'))
              ],
            );
          });
    }
    if (data['cmd'] == 'new_group_meeting' && data['status'] == 'success') {
      // Meeting scheduled successfully, display success message
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Group meeting successfully scheduled.'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'))
              ],
            );
          });
    }
  }

  void _scheduleMeetingForUsers(Map<String, dynamic> meetingData) {
    print("ScheduledMeetingForUser Called!");

    List<String> checkedUsernames = [];
    for (String user in widget.checkedUsers) {
      print(user);
      checkedUsernames.add(user);
    }
    if (checkedUsernames.isEmpty) {
      print('checkedUsernames is empty');
    }
    print(checkedUsernames);

    final payload = json.encode({
      'auth': 'chatappauthkey231r4',
      'cmd': 'new_group_meeting',
      'oid': '${widget.session_id}',
      'event': meetingData,
      'usernames': checkedUsernames,
      'group_id': '${widget.groupId}',
    });

    print('Sending payload: $payload'); // Add print statement

    _channel?.sink.add(payload);
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _eventNameController = TextEditingController();

    return AlertDialog(
      title: const Text('Schedule a Meeting'),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Name',
                  hintText: 'Enter a name for your meeting',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for your meeting';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              const Text('Start Time'),
              TextButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _startTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_startTime),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _startTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(_startTime),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text('End Time'),
              TextButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _endTime,
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
                        _endTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(_endTime),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newMeeting = Meeting(
                      _eventNameController.text,
                      _startTime,
                      _endTime,
                      Colors.yellow,
                      false,
                    );

                    final meetingData = {
                      'title': widget.groupName,
                      'start': newMeeting.from.toUtc().toIso8601String(),
                      'end': newMeeting.to.toUtc().toIso8601String(),
                    };

                    print("meetingData: $meetingData\n");
                    print("Group ID: ${widget.groupId}\n");
                    print("Session ID: ${widget.session_id}\n");
                    print("Username: ${widget.checkedUsers.first}\n");
                    print("Attempting to schedule meetings for users!\n");
                    _scheduleMeetingForUsers(meetingData);
                  }
                  // Navigator.pop(context);
                },
                child: const Text('Schedule Meeting for All Members'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
