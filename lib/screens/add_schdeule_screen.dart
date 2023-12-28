import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedulera_app/models/user.dart';
import 'package:schedulera_app/provider/user_provider.dart';
import 'package:schedulera_app/resources/firestore_methods.dart';
import 'package:schedulera_app/utils/color.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:schedulera_app/utils/utils.dart';
import 'package:schedulera_app/widgets/post_schedule.dart';

class AddSchedule extends StatefulWidget {
  const AddSchedule({Key? key}) : super(key: key);

  @override
  State<AddSchedule> createState() => _AddScheduleState();
}

class _AddScheduleState extends State<AddSchedule> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  bool _isLoading = false;

  // Function to check if end time is greater than start time
  bool isEndTimeValid() {
    DateTime startTime = DateTime.parse(_startTimeController.text);
    DateTime endTime = DateTime.parse(_endTimeController.text);
    return endTime.isAfter(startTime);
  }

  // Function to check if the selected start date is not in the past
  bool isStartDateValid() {
    DateTime startDate = DateTime.parse(_startTimeController.text);
    return startDate.isAfter(DateTime.now());
  }

  void createSchedule(String uid, String username) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Check if end time is greater than start time
      if (!isEndTimeValid()) {
        showSnackBar('End time must be greater than start time', context);
        return;
      }

      // Check if start date is not in the past
      if (!isStartDateValid()) {
        showSnackBar('Start date must be in the future', context);
        return;
      }

      DateTime startTime = DateTime.parse(_startTimeController.text);
      DateTime endTime = DateTime.parse(_endTimeController.text);
      String res = await FirestoreMethods().uploadSchdeule(
        _descriptionController.text,
        _titleController.text,
        uid,
        startTime,
        endTime,
      );

      if (res == 'success') {
        showSnackBar('Created', context);
        _titleController.clear();
        _descriptionController.clear();
        _startTimeController.clear();
        _endTimeController.clear();
      } else {
        showSnackBar(res, context);
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text(
          'Create Schedule',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        actions: [
          ElevatedButton(
            onPressed: () => createSchedule(user.uid, user.username),
            style: ElevatedButton.styleFrom(
              primary: blueColor,
              textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Start Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DateTimePicker(
                    type: DateTimePickerType.dateTime,
                    controller: _startTimeController,
                    decoration: InputDecoration(
                      labelText: 'Select Start Time',
                      border: OutlineInputBorder(),
                    ),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                    dateLabelText: 'Date',
                    timeLabelText: 'Time',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'End Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DateTimePicker(
                    type: DateTimePickerType.dateTime,
                    controller: _endTimeController,
                    decoration: InputDecoration(
                      labelText: 'Select End Time',
                      border: OutlineInputBorder(),
                    ),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                    dateLabelText: 'Date',
                    timeLabelText: 'Time',
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
