// ignore_for_file: file_names

import 'package:firebase_database/firebase_database.dart';

class UserInfoScreenFirebase {
  static final DatabaseReference _db = FirebaseDatabase.instance.ref('user');

  static Future<void> addUser(
      {required String userName, required String email}) async {
    String key = _db.push().key!;
    await _db.child(key).set({
      'key': key,
      'userName': userName,
      'email': email,
    });
  }
}
