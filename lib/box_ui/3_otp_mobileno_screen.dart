// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class OtpsendingScreen3 extends StatefulWidget {
  const OtpsendingScreen3({super.key});

  @override
  State<OtpsendingScreen3> createState() => _OtpsendingScreen3State();
}

class _OtpsendingScreen3State extends State<OtpsendingScreen3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hi There!',
                  style: GoogleFonts.yatraOne(
                    textStyle: const TextStyle(fontSize: 40),
                  ),
                ),
                const Text(
                  'Please enter a 10-digit vaild mobile',
                  style: TextStyle(fontSize: 19),
                ),
                const Text(
                  'number to recive OTP',
                  style: TextStyle(fontSize: 19),
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IntlPhoneField(
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                    initialCountryCode: 'IN',
                    onChanged: (phone) {},
                  ),
                ),
                const Text('By proceeding. you agree to the'),
                const Text.rich(
                  TextSpan(
                      text: 'Terms and condition',
                      style: TextStyle(
                        color: Color.fromARGB(255, 45, 167, 162),
                      ),
                      children: [
                        TextSpan(
                            text: '  and  ',
                            style: TextStyle(color: Colors.black)),
                        TextSpan(text: 'Privacy Policy')
                      ]),
                ),
                const SizedBox(
                  height: 25,
                ),
                MaterialButton(
                  color: const Color.fromARGB(255, 45, 167, 162),
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 7, horizontal: 80),
                    child: Text(
                      'Get OTP',
                      style: TextStyle(color: Colors.white, fontSize: 20),
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
