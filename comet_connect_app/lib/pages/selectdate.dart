import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class SelectDate extends StatefulWidget {
  const SelectDate({Key? key}) : super(key: key);

  @override
  State<SelectDate> createState() => _SelectDateState();
}

class _SelectDateState extends State<SelectDate> {
  final List<String> _dates = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Create a temp list of events for the calendar
  final List<Meeting> _events = [    
    // Meeting(
    //   'Board Meeting',      
    //    DateTime(2023, 03, 03, 9, 0, 0),      
    //   DateTime(2023, 03, 03, 12, 0, 0),      
    //   Colors.blue,      
    //   false,    
    // ),    
    // Meeting(     
    //   'Business Lunch',     
    //    DateTime(2023, 03, 03, 12, 0, 0),      
    //    DateTime(2023, 03, 03, 13, 30, 0),      
    //    Colors.green,      
    //    false,    
    // ),    
    // Meeting(      
    //   'Conference',      
    //   DateTime(2022, 03, 02, 10, 0, 0),      
    //   DateTime(2022, 03, 02, 12, 0, 0),     
    //    Colors.pink,      
    //    false,    
    //    ),  
     ];

  bool _isModified = false;

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
                  setState(() {
                    // toggle the selection state of the tapped date
                    details.appointments?.forEach((appointment) {
                      appointment.isAllDay
                          ? appointment.isAllDay = false
                          : appointment.isAllDay = true;
                    });
                    _isModified = true;
                  });
                },
                monthViewSettings: const MonthViewSettings(showAgenda: true),
              ),
            ),

            // Button to update or save changes to calendar
           // Button to update or save changes to calendar
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
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

        // Floating Action Button to add new meetings
        FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewMeetingScreen()),
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
      
      ]
      )
      )
      );
  }
}

class NewMeetingScreen extends StatefulWidget {
  @override
  _NewMeetingScreenState createState() => _NewMeetingScreenState();
}

class _NewMeetingScreenState extends State<NewMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Meeting'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                      _startTime = DateTime(pickedDate.year, pickedDate.month,
                          pickedDate.day, pickedTime.hour, pickedTime.minute);
                    });
                  }
                }
              },
              child: Text(
                '${_startTime.day}/${_startTime.month}/${_startTime.year} ${_startTime.hour}:${_startTime.minute}',
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
                      _endTime = DateTime(pickedDate.year, pickedDate.month,
                          pickedDate.day, pickedTime.hour, pickedTime.minute);
                    });
                  }
                }
              },
              child: Text(
                '${_endTime.day}/${_endTime.month}/${_endTime.year} ${_endTime.hour}:${_endTime.minute}',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(
                    context,
                    Meeting(
                      _eventNameController.text,
                      _startTime,
                      _endTime,
                      Colors.red,
                      false,
                    ),
                  );
                }
              },
              child: const Text('Create Meeting'),
            ),
          ]),
        ),
      ),
    );
  }
}

class Meeting {
  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;

  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  DateTime getendTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}
