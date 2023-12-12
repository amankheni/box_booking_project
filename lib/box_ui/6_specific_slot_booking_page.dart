// ignore_for_file: file_names, avoid_print
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

class SpecificSlotScreen6 extends StatefulWidget {
  const SpecificSlotScreen6({super.key});

  @override
  State<SpecificSlotScreen6> createState() => _SpecificSlotScreen6State();
}

class _SpecificSlotScreen6State extends State<SpecificSlotScreen6> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.arrow_back_ios_new),
          title: const Text('VIP Box Criket'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: 8,
          ),
          child: Column(
            children: [
              const Divider(
                indent: 20,
                endIndent: 20,
              ),
              Container(
                height: 40,
                width: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade300,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurStyle: BlurStyle.inner,
                    ),
                  ],
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 13,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Available Slots',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "plese select the date",
                ),
              ),
              DateTimePicker(
                initialValue: '',
                firstDate: DateTime.now(),
                lastDate: DateTime.now(),
                dateHintText: 'h',
                //  dateLabelText: 'date',
                icon: const Icon(Icons.date_range_outlined),
                onChanged: (val) => print(val),
                validator: (val) {
                  print(val);
                  return null;
                },
                onSaved: (val) => print(val),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
