import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Cards, UPI & More',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 410,
              width: 360,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
              ),
              child: const Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(7.0),
                    child: Row(
                      children: [
                        Image(
                          height: 45,
                          width: 45,
                          image: AssetImage('assets/image/credit.png'),
                        ),
                        SizedBox(
                          width: 25,
                        ),
                        Text(
                          'Card',
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(7.0),
                    child: Row(
                      children: [
                        Image(
                          height: 45,
                          width: 45,
                          image: AssetImage('assets/image/UPI Logo.png'),
                        ),
                        SizedBox(
                          width: 25,
                        ),
                        Text(
                          'UPI',
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Image(
                      height: 45,
                      width: 45,
                      image: AssetImage('assets/image/net banking.png'),
                    ),
                    title: Text('Netbanking'),
                    subtitle: Text('All indian Banks'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Image(
                      height: 45,
                      width: 45,
                      image: AssetImage('assets/image/wallet.png'),
                    ),
                    title: Text('Wallet'),
                    subtitle: Text('PhonePe & More'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Image(
                      height: 45,
                      width: 45,
                      image: AssetImage('assets/image/loan.png'),
                    ),
                    title: Text('EMI'),
                    subtitle: Text('EMI via cards & axio'),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            const Divider(),
            const Row(
              children: [
                Icon(
                  Icons.watch_later_outlined,
                  color: Colors.grey,
                ),
                Text('This page will time out in few minutes')
              ],
            ),
            const Divider(
              thickness: 7,
            ),
            const Row(
              children: [
                Text(
                  'Account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_up,
                ),
                SizedBox(
                  width: 60,
                ),
                Text('Secured by'),
                Image(
                  height: 50,
                  width: 130,
                  image: AssetImage(
                    'assets/image/RazorPay.png',
                  ),
                )
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 50,
        width: double.infinity,
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '₹ 1000/-',
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold,
                  // color: Colors.red,
                ),
              ),
              MaterialButton(
                color: const Color.fromARGB(255, 45, 167, 162),
                onPressed: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  child: Text(
                    'Pay Now',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
