import 'package:box_booking_project/Data/booking_rules_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BoxBookInfoScreen extends StatelessWidget {
  const BoxBookInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cricket Box Booking Rules'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: 10.sp,
        ),
        child: ListView.builder(
          itemCount: BookingRules.rules.length,
          itemBuilder: (context, index) {
            return _buildRuleSection(
              title: BookingRules.rules[index]['title'],
              rules: BookingRules.rules[index]['rules'],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRuleSection(
      {required String title, required List<String> rules}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              ...rules.map((rule) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.black),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            rule,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
