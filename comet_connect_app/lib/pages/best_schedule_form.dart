import 'package:flutter/material.dart';
import '../classes/meeting_class.dart';

class ScheduleMeetingForm extends StatelessWidget {
  const ScheduleMeetingForm({Key? key, required String groupId, required String session_id, required List checkedUsers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _eventNameController = TextEditingController();
    DateTime _startTime = DateTime.now();
    DateTime _endTime = DateTime.now().add(const Duration(hours: 1));

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
                      _startTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
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
                      _endTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
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
                child: const Text('Schedule Meeting for All Members'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
