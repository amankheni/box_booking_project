import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      drawer: Drawer(
        key: scaffoldKey,
        child: Text('hiiii'),
      ),
      appBar: AppBar(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            scaffoldKey.currentState!.openDrawer();
          },
          child: const Icon(
            Icons.menu_open_rounded,
            color: Color.fromARGB(255, 13, 124, 120),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Criket Box Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        //  elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(
              thickness: 3,
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/image/criket.jpg'),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Icon(
                CupertinoIcons.calendar_today,
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'No Slot Found',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: MaterialButton(
          color: const Color.fromARGB(255, 45, 167, 162),
          colorBrightness: Brightness.light,
          focusElevation: 2,
          onPressed: () {},
          child: const Padding(
            padding: EdgeInsets.only(left: 70, right: 70),
            child: Text(
              'Book now',
            ),
          ),
        ),
      ),
    );
  }
}
