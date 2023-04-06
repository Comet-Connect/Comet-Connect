import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

import '../classes/meeting_class.dart';
import '../classes/new_meeting_class.dart';

class SelectDate extends StatefulWidget {
  const SelectDate({Key? key}) : super(key: key);

  @override
  State<SelectDate> createState() => _SelectDateState();
}

class _SelectDateState extends State<SelectDate> {
  final List<String> _dates = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Create a temp list of events for the calendar
  final List<Meeting> _events = [];

  bool _isModified = false;

  // Future<void> _showMeetingDetailsPopup(Meeting meeting) async {
  //   final result = await showMenu<String>(
  //     context: context,
  //     position: RelativeRect.fill,
  //     items: [
  //       const PopupMenuItem<String>(
  //         value: 'edit',
  //         child: Text('Edit'),
  //       ),
  //       const PopupMenuItem<String>(
  //         value: 'delete',
  //         child: Text('Delete'),
  //       ),
  //     ],
  //   );

  //   switch (result) {
  //     case 'edit':
  //       // TODO: Implement edit functionality
  //       break;
  //     case 'delete':
  //       setState(() {
  //         _events.remove(meeting);
  //       });
  //       break;
  //   }
  // }

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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nav Bar
      appBar: AppBar(
        title: const Text('Comet Connect'),
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
                'My current schedule',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Calendar
            Expanded(
              child: SfCalendar(
                view: CalendarView.week,
                dataSource: MeetingDataSource(_events),
                initialSelectedDate: DateTime.now(),
                selectionDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  shape: BoxShape.rectangle,
                ),
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
                monthViewSettings: const MonthViewSettings(showAgenda: true),
                // Long press gesture on events
                onLongPress: (details) {
                  final Meeting meeting = details.appointments!.first;
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
                          Text(
                              'To: ${DateFormat('MMM d, yyyy hh:mm a').format(meeting.to)}'),
                          Text('All Day: ${meeting.isAllDay ? 'Yes' : 'No'}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
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

          // Save changes button       ** Needs to be fixed
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                if (_isModified) {
                  // TODO: Implement code to save changes to calendar
                  // For now, just print the updated events
                  print(_events);
                } else {
                  // TODO: Implement code to update the calendar
                  // For now, just update the _events list with a new meeting
                  setState(() {
                    _events.add(Meeting(
                      'New Meeting',
                      DateTime.now(),
                      DateTime.now().add(const Duration(hours: 1)),
                      Colors.yellow,
                      false,
                    ));
                  });
                }
                setState(() {
                  _isModified = !_isModified;
                });
              },
              child: Text(_isModified ? 'Save Changes' : 'Update Calendar'),
            ),
          ),
        ],
      ),
    );
  }
}
