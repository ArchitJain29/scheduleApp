import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:schedulera_app/models/user.dart' as model;
import 'package:schedulera_app/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  Future<void> updateFCMToken(String uid, String fcmToken) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({'fcmToken': fcmToken});
  }

  Future<String> singUpUser({
    required String email,
    required String password,
    required String username,
    required Uint8List file,
  }) async {
    String res = 'An error occurred';
    try {
      if (email.isNotEmpty || password.isNotEmpty || username.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        print(cred.user!.uid);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePic', file, false);

        model.User user = model.User(
          email: email,
          photoUrl: photoUrl,
          uid: cred.user!.uid,
          username: username,
          fcmToken: '',
        );

        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());

        // Store FCM token after signup
        String? fcmToken = await _firebaseMessaging.getToken();
        if (fcmToken != null) {
          await updateFCMToken(cred.user!.uid, fcmToken);
        }

        res = 'success';
      } else {
        print('hi');
      }
    } catch (err) {
      res = err.toString();
      print(res);
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred';

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Check if FCM token is present and update if necessary
        String? fcmToken = await _firebaseMessaging.getToken();
        User? currentUser = _auth.currentUser;

        if (currentUser != null && fcmToken != null) {
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(currentUser.uid).get();

          if (!userDoc.exists ||
              (userDoc.data() as Map<String, dynamic>)['fcmToken'] !=
                  fcmToken) {
            await updateFCMToken(currentUser.uid, fcmToken);
          }
        }

        res = 'success';
      } else {
        res = ' Please enter all the fields';
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
