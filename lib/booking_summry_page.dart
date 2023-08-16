import 'package:flutter/material.dart';

class BookingSummaryPage extends StatefulWidget {
  const BookingSummaryPage({super.key});

  @override
  State<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends State<BookingSummaryPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.arrow_back_ios),
          title: const Column(
            children: [
              Text(
                'Naik Box Criket',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '(Mota varachha)',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          centerTitle: true,
          elevation: 7,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'Slot Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text('(01)'),
                ],
              ),
              const Row(
                children: [
                  Text('22-Jun-2023'),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    height: 105,
                    width: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                '3:00 PM - 4:00 PM',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Naik Box Criket'),
                              Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Text(
                                '₹ 1000 /-',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
