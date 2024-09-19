// // ignore_for_file: file_names

// ignore_for_file: avoid_print, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserInfoScreenFirebase {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Store the user data with the UID as the document ID
        await _firestore.collection('users').doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("User added with ID: ${user.uid}");
      } catch (e) {
        print("Error adding user: $e");
      }
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          print("User data fetched successfully: ${doc.data()}");
          return doc.data() as Map<String, dynamic>?;
        } else {
          print("No document found for user ID: ${user.uid}");
          return null;
        }
      } catch (e) {
        print("Error fetching user data: $e");
        return null;
      }
    } else {
      print("No user is currently signed in.");
      return null;
    }
  }
}
