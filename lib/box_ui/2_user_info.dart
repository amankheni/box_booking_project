// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

import 'package:box_booking_project/network_and_database/firebase/2user_infoscreen_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserInfo2 extends StatefulWidget {
  const UserInfo2({super.key});

  @override
  State<UserInfo2> createState() => _UserInfo2State();
}

class _UserInfo2State extends State<UserInfo2> {
  final GlobalKey<FormState> key = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  late Future<List<Map>> futureUserData;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: key,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie.asset('assets/image/criket ever.json'),
                Text(
                  'We\'re all Set',
                  style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(fontSize: 30),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your Name';
                    }
                    if (value.length >= 20) {
                      return 'Please enter a maximum 20 charecter name';
                    }
                    // if (RegExp("[^p{L}ds_]").hasMatch(value)) {
                    //   return "special charecter is not valid";
                    // }

                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value!)) {
                      return "Please enter a valid email address";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                MaterialButton(
                  color: const Color.fromARGB(255, 45, 167, 162),
                  onPressed: () async {
                    await UserInfoScreenFirebase.addUser(
                        userName: nameController.text,
                        email: emailController.text);

                    if (key.currentState!.validate()) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data Varified')));
                    }
                    setState(() {});
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    child: Text(
                      'Let\'s Go ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
