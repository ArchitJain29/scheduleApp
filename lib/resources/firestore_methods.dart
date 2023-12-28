import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedulera_app/models/schedule.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadSchdeule(String description, String title, String uid,
      DateTime startTime, DateTime endTime) async {
    String res = "some error occured";
    String scheduleId = const Uuid().v1();
    try {
      Schedule schedule = Schedule(
        uid: uid,
        title: title,
        description: description,
        scheduleId: scheduleId,
        startTime: startTime,
        endTime: endTime,
      );

      _firestore.collection('schedules').doc(scheduleId).set(schedule.toJson());
      res = 'success';
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  Future<void> deletePost(String scheduleId) async {
    try {
      await _firestore.collection('schedules').doc(scheduleId).delete();
    } catch (err) {
      print(err.toString());
    }
  }
}
