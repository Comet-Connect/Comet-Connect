import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'selectdate.dart';


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