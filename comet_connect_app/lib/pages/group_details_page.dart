// ignore_for_file: non_constant_identifier_names, avoid_print, library_private_types_in_public_api

import 'dart:convert';
import 'package:comet_connect_app/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config.dart';
import 'best_schedule_form.dart';

final grayMaterialStateProperty =
    MaterialStateProperty.all<Color>(Colors.grey[800]!);

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
  final List<dynamic> _checkedUsers = [];
  List<_Meeting> _events = [];

  DateTime date = DateTime.now();
  WebSocketChannel? _channel;
  List colors = [
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.blue
  ];
  late int index;

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
      _channel?.stream.listen(_handleWebSocketMessage);
    } catch (e) {
      print('WebSocket connection failed: $e');
    }
  }

  void _handleWebSocketMessage(message) {
    final data = json.decode(message);
    print('Decoded data: $data');
    print('Received data from server: \n\t$message');

    if (data['cmd'] == 'pull_group_events') {
      List<dynamic> users = data['users'];
      List<_Meeting> events = [];
      index = 0;
      for (var user in users) {
        String username = user['username'];
        
        Color temp = colors[index % colors.length];
        List<dynamic> userEvents = user['events'];
        for (var event in userEvents) {
          events.add(_Meeting(
            user: username,
            from: DateTime.parse(event['start']).toLocal(),
            to: DateTime.parse(event['end']).toLocal(),
            eventName: "$username:", //${event['title']}",
            background: temp, //Colors.blue,
          ));
        }
        index++;
      }
      print('Parsed events: $events');
      setState(() {
        _events = events;
      });

      // Navigate to the GroupCalendarPage after updating the events
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => GroupCalendarPage(events: _events),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.groupName),
          backgroundColor: UTD_color_primary,
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              Row(
                children: [
                  const Text('Current Users in the Group:',
                      style: TextStyle(fontSize: 20.0)),
                  const Spacer(),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: grayMaterialStateProperty),
                      onPressed: () {
                        setState(() {
                          for (var user in widget.users) {
                            _checkedUsers.add(user['username']);
                          }
                        });
                      },
                      child: const Text(
                        'Select All Users',
                        style: TextStyle(color: Colors.white),
                      )),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: grayMaterialStateProperty),
                      onPressed: () {
                        setState(() {
                          _checkedUsers.clear();
                        });
                      },
                      child: const Text(
                        'Deselect All Users',
                        style: TextStyle(color: Colors.white),
                      ))
                ],
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

              // Generate Schedules and View Group Availability
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Group Availability

                  ElevatedButton(
                    onPressed: () {
                      // Send a message to the server requesting group events
                      _channel?.sink.add(json.encode({
                        "auth": "chatappauthkey231r4",
                        "cmd": "pull_group_events",
                        "group_id": widget.groupId,
                        "usernames": _checkedUsers
                      }));
                    },
                    style:
                        ButtonStyle(backgroundColor: grayMaterialStateProperty),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.calendar_today, color: Colors.white),
                        SizedBox(width: 10, height: 10),
                        Text(' View Group Availability',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0, width: 10),
                  // Schedule a Group Meeting
                  ElevatedButton(
                    // Pass in the users that are checked to put in scheduling alg
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ScheduleMeetingForm(
                              groupId: widget.groupId,
                              session_id: widget.session_id,
                              checkedUsers: _checkedUsers);
                        },
                      );
                    },
                    style:
                        ButtonStyle(backgroundColor: grayMaterialStateProperty),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.schedule, color: Colors.white),
                        SizedBox(width: 20, height: 10),
                        Text(' Schedule Group Meeting',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ])));
  }
}

class GroupCalendarPage extends StatefulWidget {
  final List<_Meeting> events;

  const GroupCalendarPage({Key? key, required this.events}) : super(key: key);

  @override
  _GroupCalendarPageState createState() => _GroupCalendarPageState();
}

class _GroupCalendarPageState extends State<GroupCalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Calendar'),
        backgroundColor: UTD_color_primary, // Header color
      ),
      body: SizedBox(
        child: SfCalendar(
          allowedViews: const [
            CalendarView.schedule,
            CalendarView.timelineDay,
            CalendarView.week,
            CalendarView.timelineWeek,
            CalendarView.month,
          ],
          view: CalendarView.week,
          dataSource: _DataSource(widget.events),
          monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          ),
          scheduleViewMonthHeaderBuilder: (BuildContext buildContext,
              ScheduleViewMonthHeaderDetails details) {
            return Text("${details.date.month}/${details.date.year}");
          },
          onTap: (CalendarTapDetails calendarTapDetails) {
            if (calendarTapDetails.targetElement ==
                    CalendarElement.appointment ||
                calendarTapDetails.targetElement == CalendarElement.agenda) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(calendarTapDetails.appointments![0].subject),
                    content: Text(
                        'Start Time: ${calendarTapDetails.appointments![0].startTime}\n'
                        'End Time: ${calendarTapDetails.appointments![0].endTime}'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      )
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class _Meeting {
  _Meeting({
    required this.user,
    required this.from,
    required this.to,
    required this.eventName,
    required this.background,
  });

  final String user;
  final DateTime from;
  late final DateTime to;
  final String eventName;
  final Color background;
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<_Meeting> source) {
    appointments = source
        .map((meeting) => Appointment(
            notes: meeting.user,
            startTime: meeting.from,
            endTime: meeting.to,
            subject: meeting.eventName,
            color: meeting.background))
        .toList();
  }
}

// Widget to display a loading indicator
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
