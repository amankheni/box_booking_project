import 'package:cloud_firestore/cloud_firestore.dart';

class BookingController {
  static List<Map<String, dynamic>> boxList = [];

  static Future<void> fetchBoxDetails() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('boxes').get();
    boxList = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }
}
