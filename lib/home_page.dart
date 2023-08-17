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
    return SafeArea(
      child: Scaffold(
        drawer: const Drawer(
          width: 230,
          backgroundColor: Color.fromARGB(255, 216, 247, 240),
          child: Padding(
            padding: EdgeInsets.only(
              top: 150,
              left: 16,
              right: 8,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Icon(
                    //  CupertinoIcons.person_alt,
                    Icons.person_2_outlined,

                    color: Colors.black,
                    size: 50,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 35,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 30,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      'Box book info',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 30,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      'History',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.logout_outlined,
                      size: 30,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.share_rounded,
                      size: 30,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      'Share App',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.wallet_rounded,
                      size: 30,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      'Payment',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        key: scaffoldKey,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                    child: const Icon(
                      Icons.menu_open_rounded,
                      color: Color.fromARGB(255, 13, 124, 120),
                      size: 30,
                    ),
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  const Text(
                    'Criket Box Booking',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
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
      ),
    );
  }
}




// appBar: AppBar(
        //   key: scaffoldKey,
        //   backgroundColor: Colors.white,
        //   leading: GestureDetector(
        //     onTap: () {
        //       scaffoldKey.currentState?.openDrawer();
        //     },
        //     child: const Icon(
        //       Icons.menu_open_rounded,
        //       color: Color.fromARGB(255, 13, 124, 120),
        //     ),
        //   ),
        //   centerTitle: true,
        //   title: const Text(
        //     'Criket Box Booking',
        //     style: TextStyle(fontWeight: FontWeight.bold),
        //   ),
        //   //  elevation: 2,
        // ),