import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Schedule {
  final String uid;
  final String title;
  final String description;
  final String scheduleId;
  final DateTime startTime;
  final DateTime endTime;

  const Schedule({
    required this.uid,
    required this.title,
    required this.description,
    required this.scheduleId,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'uid': uid,
        'title': title,
        'scheduleId': scheduleId,
        'startTime': startTime.toUtc(),
        'endTime': endTime.toUtc()
      };

  static Schedule fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Schedule(
        uid: snapshot['uid'],
        title: snapshot['title'],
        scheduleId: snapshot['scheduleId'],
        description: snapshot['description'],
        startTime: (snapshot['startTime'] as Timestamp).toDate(),
        endTime: (snapshot['endTime'] as Timestamp).toDate());
  }
}
