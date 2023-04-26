import 'package:comet_connect_app/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'best_schedule_form.dart';

final grayMaterialStateProperty =
    MaterialStateProperty.all<Color>(Colors.grey[800]!);

/// GroupDetailsPage Class
///
/// This is Groups Details Page of a Group for the Comet Connect App
/// Contains:
///    - Group Details
///        - Group ID
///        - Group Name
///        - Session ID
///    - Current Users in Group
///        - Username
///        - Calendar ID
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
  final List<String> _checkedUsers = [];
  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.groupName}'),
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
                          widget.users.forEach((user) {
                            _checkedUsers.add(user['username']);
                          });
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
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => GroupCalendarPage(),
                      ));
                      // setState(() {
                      //   _showCalendar = true;
                      // });
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
                          return const ScheduleMeetingForm();
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

// Calendar for Group
              // if (_showCalendar)
              //   Stack(
              //     children: [
              //       SizedBox(
              //         height: 350,
              //         child: Expanded(
              //           child: SfCalendar(
              //             view: CalendarView.week,
              //             dataSource: _DataSource([
              //               _Meeting(
              //                 user: 'Alice',
              //                 from: DateTime.now().add(const Duration(days: 1)),
              //                 to: DateTime.now()
              //                     .add(const Duration(days: 1, hours: 1)),
              //                 eventName: 'Meeting with Bob',
              //                 background: Colors.red,
              //               ),
              //               _Meeting(
              //                 user: 'Bob',
              //                 from: DateTime.now().add(const Duration(days: 2)),
              //                 to: DateTime.now()
              //                     .add(const Duration(days: 2, hours: 2)),
              //                 eventName: 'Lunch with Alice',
              //                 background: Colors.green,
              //               ),
              //               _Meeting(
              //                 user: 'Charlie',
              //                 from: DateTime.now().add(const Duration(days: 3)),
              //                 to: DateTime.now()
              //                     .add(const Duration(days: 3, hours: 3)),
              //                 eventName: 'Call with Alice and Bob',
              //                 background: Colors.blue,
              //               ),
              //             ]),
              //           ),
              //         ),
              //       ),
              //       Positioned(
              //         top: 0,
              //         right: 0,
              //         child: ElevatedButton(
              //           onPressed: () {
              //             setState(() {
              //               _showCalendar = false;
              //             });
              //           },
              //           style: ButtonStyle(
              //               backgroundColor: MaterialStateProperty.all<Color>(
              //                   Colors.grey[800]!),
              //               fixedSize: MaterialStateProperty.all<Size>(
              //                   const Size(220, 20))),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.start,
              //             children: const [
              //               Icon(Icons.hide_source, color: Colors.white),
              //               SizedBox(width: 10, height: 10),
              //               Text(' Hide Calendar',
              //                   style: TextStyle(color: Colors.white)),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
            ])));
  }
}

class GroupCalendarPage extends StatefulWidget {
  const GroupCalendarPage({Key? key}) : super(key: key);

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
        
        child: Expanded(
          child: SfCalendar(

            allowedViews: const [
                  CalendarView.schedule,
                  CalendarView.day,
                  CalendarView.week,
                  CalendarView.workWeek,
                  CalendarView.month,
                  CalendarView.timelineDay,
                  CalendarView.timelineWeek,
                  CalendarView.timelineWorkWeek
                ],

                
            view: CalendarView.week,
            dataSource: _DataSource([
              _Meeting(
                user: 'Alice',
                from: DateTime.now().add(const Duration(days: 1)),
                to: DateTime.now().add(const Duration(days: 1, hours: 1)),
                eventName: 'Meeting with Bob',
                background: Colors.red,
              ),
              _Meeting(
                user: 'Bob',
                from: DateTime.now().add(const Duration(days: 2)),
                to: DateTime.now().add(const Duration(days: 2, hours: 2)),
                eventName: 'Lunch with Alice',
                background: Colors.green,
              ),
              _Meeting(
                user: 'Charlie',
                from: DateTime.now().add(const Duration(days: 3)),
                to: DateTime.now().add(const Duration(days: 3, hours: 3)),
                eventName: 'Call with Alice and Bob',
                background: Colors.blue,
              ),
            ]),
          ),
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
  final DateTime to;
  final String eventName;
  final Color background;
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<_Meeting> source) {
    appointments = source
        .map((meeting) => Appointment(
            startTime: meeting.from,
            endTime: meeting.to,
            subject: meeting.eventName,
            color: meeting.background))
        .toList();
  }
}
