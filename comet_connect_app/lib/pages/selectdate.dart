// ignore_for_file: avoid_print, depend_on_referenced_packages, avoid_function_literals_in_foreach_calls

import 'dart:convert';
import 'package:comet_connect_app/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../auth/login.dart';
import '../classes/meeting_class.dart';
import '../classes/new_meeting_class.dart';
import 'package:comet_connect_app/config.dart';

/// SelectDate Class
///
/// This is the Calendar Page of the Comet Connect App
/// Contains:
///    - Events/Meetings
///    - Meeting details
///    - User Availability
///    - Create Meeting Functionality
///    - Delete Meeting Functionality
class SelectDate extends StatefulWidget {
  const SelectDate({Key? key}) : super(key: key);

  @override
  State<SelectDate> createState() => _SelectDateState();
}

class _SelectDateState extends State<SelectDate> {
  // Create a temp list of events for the calendar
  final List<Meeting> _events = [];
  final CalendarController _controller = CalendarController();
  Color? _headerColor, _viewHeaderColor, _calendarColor;
  bool _isModified = false;

  WebSocketChannel? _channel;

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
    Map config = await getServerConfigFile();

    // Open a new WebSocket connection, Connecting to WS Server
    if (config.containsKey("is_server") && config["is_server"] == "1") {
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://${config["host"]}/ws'),
      );
    } else {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://${config["host"]}:${config["port"]}'),
      );
    }

    // Check if current logged in user is not null
    if (current_loggedin_user != null) {
      _getCalendar();
    }

    // Listen for messages from the server
    _channel?.stream.listen((message) {
      //message = message.replaceAll(RegExp("'"), '"');
      final data = json.decode(message);

      // Print received data
      print('Received data from server: \n\t$message');

      // Pull User Calendar
      if (data['cmd'] == 'calendar') {
        // Update the list of events with the calendar data received from the server
        setState(() {
          //_events.clear();
          final eventsData = data['events'] as List<dynamic>;
          eventsData.forEach((eventData) {
            // Format Meeting color ETC.
            final meeting = Meeting(
              eventData['title'] as String,
              DateTime.parse(eventData['start'] as String).toLocal(),
              DateTime.parse(eventData['end'] as String).toLocal(),
              UTD_color_secondary, // Set a default color for now
              false, // All-day flag not supported yet
            );
            _events.add(meeting);
          });
          print('Received ${_events.length} events:');
          _events.forEach((event) {
            print(event.eventName);
          });
        });
      }
    });
  }
  
  void _getCalendar() {
    final userId = current_loggedin_user_oid;
    _channel?.sink.add(json.encode({
      'cmd': 'get_calendar',
      'oid': userId,
    }));
  }

  // Display Meeting Details
  void _showMeetingDetailsPopup(Meeting meeting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meeting Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event Name: ${meeting.eventName}'),
            Text(
                'From: ${DateFormat('MMM d, yyyy hh:mm a').format(meeting.from)}'),
            Text('To: ${DateFormat('MMM d, yyyy hh:mm a').format(meeting.to)}'),
            Text('All Day: ${meeting.isAllDay ? 'Yes' : 'No'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.pop(context);

              // Show a confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Meeting'),
                  content: const Text(
                      'Are you sure you want to delete this meeting?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Delete the meeting from the list of events
                        setState(() {
                          _events.remove(meeting);
                        });

                        // Send request to delete the meeting from the backend
                        final userId = current_loggedin_user_oid;
                        _channel?.sink.add(json.encode({
                          'cmd': 'delete_meeting',
                          'oid': userId,
                          'title': meeting.eventName,
                          'start': meeting.from.toIso8601String(),
                          'end': meeting.to.toIso8601String(),
                        }));

                        // Close the confirmation dialog
                        Navigator.pop(context);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Building Calendar Page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nav Bar
      appBar: AppBar(
        title: const Text('Comet Connect'),
        backgroundColor: UTD_color_primary, // Header color
      ),

      // Main Body
      body: Padding(
        // Padding around all edges
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10),
              child: const Text(
                //'Select dates and times that work for you',
                'My Schedule',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Divider(thickness: 2),
            // Calendar Widget
            Expanded(
              child: SfCalendar(
                /* Change view:  
                  - CalendarView.week
                  - CalendarView.schedule
                */
                allowedViews: const [
                  CalendarView.schedule,
                  CalendarView.timelineDay,
                  CalendarView.week,
                  CalendarView.timelineWeek,
                  CalendarView.month,
                ],

                viewHeaderStyle:
                    ViewHeaderStyle(backgroundColor: _viewHeaderColor),
                backgroundColor: _calendarColor,
                controller: _controller,
                initialDisplayDate: DateTime.now(),

                view: CalendarView.week, // View of Calendar
                dataSource: MeetingDataSource(_events), // Stores Meetings
                todayHighlightColor: UTD_color_primary,
                cellBorderColor: Colors.grey[500],
                showNavigationArrow: true,
                initialSelectedDate:
                    DateTime.now(), // Cursor to depick current time
                showWeekNumber: true,
                // edit colors etc. of box border
                selectionDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: UTD_color_primary, width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  shape: BoxShape.rectangle,
                ),

                // Tapping on a Meeting
                onTap: (details) {
                  if (details.appointments != null &&
                      details.appointments!.isNotEmpty) {
                    _showMeetingDetailsPopup(
                        details.appointments![0] as Meeting);
                  }
                  setState(() {
                    _isModified = true;
                  });
                },

                // TODO: Long hold press not working
                onLongPress: (details) {
                  final appointment = details.appointments!.first;
                  final startTime = appointment.startTime;
                  final endTime = appointment.endTime;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Adjust Time Range'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('From: ${startTime.toString()}'),
                            Text('To: ${endTime.toString()}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Update start and end times
                              setState(() {
                                final newAppointment = Meeting(
                                  appointment.eventName,
                                  startTime,
                                  endTime.add(const Duration(hours: 1)),
                                  appointment.color,
                                  appointment.isAllDay,
                                );
                                _events.remove(appointment);
                                _events.add(newAppointment);
                              });

                              Navigator.pop(context);
                            },
                            child: const Text('Update'),
                          ),
                        ],
                      );
                    },
                  );
                },
                monthViewSettings: const MonthViewSettings(showAgenda: true),
              ), // End of SFCalendar
            ),
          ],
        ),
      ),

      // Floating Action Buttons
      floatingActionButton: Stack(
        children: [
          // Add new meeting FAB
          Positioned(
            bottom: 5,
            left: 20,
            child: FloatingActionButton(
              backgroundColor: UTD_color_primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NewMeetingScreen()),
                ).then((newMeeting) {
                  if (newMeeting != null) {
                    setState(() {
                      _events.add(newMeeting);
                    });
                  }
                });
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
