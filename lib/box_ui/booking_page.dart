import 'package:box_booking_project/booking_page_controller.dart';
import 'package:box_booking_project/box_ui/booking_summry_page.dart';
import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.arrow_back_ios_new,
        ),
        centerTitle: true,
        title: const Text(
          'Box Booking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 3,
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: 50,
                width: 330,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Serach Box near by You',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: BookingController.boxList.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookingSummaryPage(),
                      ));
                  setState(() {});
                },
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        AssetImage(BookingController.boxList[index]['asset']),
                  ),
                  title: Text(BookingController.boxList[index]['boxName']),
                  subtitle: Text(BookingController.boxList[index]['area']),
                ),
              ),
            ),
          ),
          // Column(
          //   children: List.generate(
          //     BookingController.boxList.length,
          //     (index) => Column(
          //       children: [
          //         ListTile(
          //           leading: const CircleAvatar(),
          //           title: Text(
          //             BookingController.boxList[index]['boxName'],
          //             style: const TextStyle(
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //           subtitle:
          //               Text('(${BookingController.boxList[index]['area']})'),
          //         ),
          //         const Divider(),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
