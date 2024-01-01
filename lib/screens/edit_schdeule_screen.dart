import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditScheduleScreen extends StatefulWidget {
  final String scheduleId;

  const EditScheduleScreen({Key? key, required this.scheduleId})
      : super(key: key);

  @override
  _EditScheduleScreenState createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();

  String _formatDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMMM d, y HH:mm').format(dateTime);
  }

  DateTime _parseDateTime(String dateTimeString) {
    return DateFormat('MMMM d, y HH:mm').parse(dateTimeString);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void updateSchedule(String scheduleId) async {
    try {
      await FirebaseFirestore.instance
          .collection('schedules')
          .doc(scheduleId)
          .update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'startTime':
            Timestamp.fromDate(_parseDateTime(_startTimeController.text)),
        'endTime': Timestamp.fromDate(_parseDateTime(_endTimeController.text)),
      });

      // Display a success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Schedule updated successfully'),
        backgroundColor: Colors.green,
      ));

      // Navigate back to the previous screen
      Navigator.pop(context);
    } catch (e) {
      // Display an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating schedule: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _pickDateTime(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _parseDateTime(controller.text),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          controller.text = _formatDateTime(Timestamp.fromDate(pickedDateTime));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('schedules')
              .doc(widget.scheduleId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return Center(child: Text('Schedule not found'));
            }

            var scheduleData = snapshot.data!.data() as Map<String, dynamic>;

            _titleController.text = scheduleData['title'];
            _descriptionController.text = scheduleData['description'];
            _startTimeController.text =
                _formatDateTime(scheduleData['startTime']);
            _endTimeController.text = _formatDateTime(scheduleData['endTime']);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _pickDateTime(_startTimeController),
                  child: TextField(
                    controller: _startTimeController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Start Time',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _pickDateTime(_endTimeController),
                  child: TextField(
                    controller: _endTimeController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'End Time',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    updateSchedule(widget.scheduleId);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Update Schedule',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
