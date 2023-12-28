import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedulera_app/resources/firestore_methods.dart';
import 'package:schedulera_app/screens/edit_schdeule_screen.dart';
import 'package:schedulera_app/utils/color.dart';

class PostScheduleScreen extends StatelessWidget {
  final snap;

  const PostScheduleScreen({Key? key, required this.snap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract data from snap
    String title = snap['title'] ?? '';
    String description = snap['description'] ?? '';
    DateTime startTime =
        (snap['startTime'] as Timestamp).toDate() ?? DateTime.now();
    DateTime endTime =
        (snap['endTime'] as Timestamp).toDate() ?? DateTime.now();
    Duration duration = endTime.difference(startTime);

    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Card(
        elevation: 4.0,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Show menu
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit Button
                                Container(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditScheduleScreen(
                                                  scheduleId:
                                                      snap['scheduleId']),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.blue,
                                      minimumSize: Size(double.infinity, 50),
                                    ),
                                    child: Text('Edit',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                                SizedBox(height: 8),

                                // Delete Button
                                Container(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      FirestoreMethods()
                                          .deletePost(snap['scheduleId']);
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                      minimumSize: Size(double.infinity, 50),
                                    ),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.more_vert),
                  )
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Description: $description',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Start Time: ${_formatDateTime(startTime)}',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'End Time: ${_formatDateTime(endTime)}',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Duration: ${_formatDuration(duration)}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        clipBehavior: Clip.antiAlias,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours.abs() >= 24) {
      // If duration is more than or equal to 24 hours, show it in days
      return '${duration.inDays} days';
    } else {
      // Otherwise, show it in hours
      return '${duration.inHours} hours';
    }
  }
}
