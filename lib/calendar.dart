import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'dart:math';

class CalendarPage extends StatefulWidget {

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? selectedDate;
  Random random = new Random();
  @override
  void initState (){
  setState(() {
    selectedDate = DateTime.now();
});
  super.initState();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: CalendarAppBar(
            padding: 8,
            accent: Colors.deepOrangeAccent,
            onDateChanged: (value) => setState(() => selectedDate = value),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 30)),
            events: List.generate(100, (index) => DateTime.now().add(Duration(days: index * random.nextInt(5)))),
        ),
        body: ListView.builder(
            itemCount: 3,
            itemBuilder: (context,index){
                return ListTile(
                  leading: Icon(Icons.event),
                  title: Text('No event listed yet'),
                  trailing: Text(selectedDate.toString(), style: TextStyle(fontSize: 11)),
                );
        })
      );
  }
}
/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/foundation.dart';
class Event {
  final String title;
  final String description;
  final DateTime startDateTime;
  final DateTime endDateTime;

  Event({
    required this.title,
    required this.description,
    required this.startDateTime,
    required this.endDateTime,
  });
}

class FirebaseService {
  final CollectionReference eventsCollection =
  FirebaseFirestore.instance.collection('events');

  Future<void> addEvent(Event event) {
    return eventsCollection.add({
      'title': event.title,
      'description': event.description,
      'startDateTime': event.startDateTime,
      'endDateTime': event.endDateTime,
    });
  }

  Stream<List<Event>> getEvents() {
    return eventsCollection.snapshots().map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          return Event(
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            startDateTime: (data['startDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
            endDateTime: (data['endDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        }).toList();
      } else {
        // Handle the case when the snapshot doesn't have any data yet
        return [];
      }
    });
  }


}


class EventCalendarScreen extends StatefulWidget {
  @override
  _EventCalendarScreenState createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  final FirebaseService firebaseService = FirebaseService();
  late CalendarController _calendarController;
  late Stream<List<Event>> _eventsStream;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _eventsStream = firebaseService.getEvents();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            calendarController: _calendarController,
          ),
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: _eventsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final events = snapshot.data!;
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return ListTile(
                        title: Text(event.title),
                        subtitle: Text(event.description),
                        trailing: Text(
                          '${event.startDateTime} - ${event.endDateTime}',
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open a dialog to add a new event
          showDialog(
            context: context,
            builder: (context) => AddEventDialog(
              onEventAdded: (event) {
                firebaseService.addEvent(event);
              },
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddEventDialog extends StatefulWidget {
  final Function(Event) onEventAdded;

  AddEventDialog({required this.onEventAdded});

  @override
  _AddEventDialogState createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _selectedStartDate = DateTime.now();
    _selectedEndDate = DateTime.now().add(Duration(hours: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Event'),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Start Date and Time:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            DateTimePicker(
              initialValue: _selectedStartDate,
              firstDate: DateTime(2021),
              lastDate: DateTime(2030),
              onChanged: (selectedDate) {
                setState(() {
                  _selectedStartDate = selectedDate;
                });
              },
            ),
            SizedBox(height: 16.0),
            Text(
              'End Date and Time:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            DateTimePicker(
              initialValue: _selectedEndDate,
              firstDate: DateTime(2021),
              lastDate: DateTime(2030),
              onChanged: (selectedDate) {
                setState(() {
                  _selectedEndDate = selectedDate;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newEvent = Event(
                title: _titleController.text,
                description: _descriptionController.text,
                startDateTime: _selectedStartDate,
                endDateTime: _selectedEndDate,
              );
              widget.onEventAdded(newEvent);
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

class DateTimePicker extends StatelessWidget {
  final DateTime initialValue;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;

  DateTimePicker({
    required this.initialValue,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: initialValue,
          firstDate: firstDate,
          lastDate: lastDate,
        );
        if (selectedDate != null) {
          final selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(initialValue),
          );
          if (selectedTime != null) {
            final selectedDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            onChanged(selectedDateTime);
          }
        }
      },
      child: IgnorePointer(
        child: TextFormField(
          readOnly: true,
          controller: TextEditingController(
            text: initialValue.toString(),
          ),
          decoration: InputDecoration(
            labelText: 'Select Date and Time',
            suffixIcon: Icon(Icons.calendar_today),
          ),
        ),
      ),
    );
  }
}*/
