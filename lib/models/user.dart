import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String fcmToken; // Added field for FCM token

  const User({
    required this.email,
    required this.photoUrl,
    required this.uid,
    required this.username,
    required this.fcmToken, // Added field for FCM token
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'email': email,
        'photoUrl': photoUrl,
        'fcmToken': fcmToken, // Added field for FCM token
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      email: snapshot['email'],
      photoUrl: snapshot['photoUrl'],
      uid: snapshot['uid'],
      username: snapshot['username'],
      fcmToken: snapshot['fcmToken'] ?? '', // Added field for FCM token
    );
  }
}
