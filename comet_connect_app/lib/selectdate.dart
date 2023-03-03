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
    Meeting(
      'Board Meeting',
      DateTime(2023, 03, 03, 9, 0, 0),
      DateTime(2023, 03, 03, 12, 0, 0),
      Colors.blue,
      false,
    ),
    Meeting(
      'Business Lunch',
      DateTime(2023, 03, 03, 12, 0, 0),
      DateTime(2023, 03, 03, 13, 30, 0),
      Colors.green,
      false,
    ),
    Meeting(
      'Conference',
      DateTime(2022, 03, 02, 10, 0, 0),
      DateTime(2022, 03, 02, 12, 0, 0),
      Colors.pink,
      false,
    ),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nav Bar
      appBar: AppBar(
        title: const Text('Comet Connect'),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Home'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('View Calendar'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile( 
              title: const Text('View Groups'),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
                
              },
            ),
            ListTile(
              title: const Text('Help'),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            // Sign out option
            ListTile(
              title: const Text('Sign Out'),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
                // Call Sign Out function

                
              }
            ),


          ],
        ),
      ),

      // Main Body
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20, bottom: 10),
            child: const Text(
              'Select dates and times that work for you',
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
                });
              },
              monthViewSettings: const MonthViewSettings(showAgenda: true),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _dates
                .map((day) => Container(
                      width: 60,
                      height: 40,
                      margin: const EdgeInsets.all(5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Text(day),
                    ))
                .toList(),
          ),
        ],
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

  @override
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
