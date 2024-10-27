import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:helth_management/screens/Dashboard.dart';
import 'package:helth_management/screens/LoginPage.dart';

import 'package:helth_management/screens/all_appointments.dart';

class PaymentSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Success'),
        automaticallyImplyLeading: false, // To disable the back button
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 120, // Big success arrow
            ),
            SizedBox(height: 20),
            Text(
              'Payment Successful',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Your payment has been succesfully processed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => Dashboard(
                  name: globalUserData?['full_name'] ?? 'User',
                  userId: FirebaseAuth.instance.currentUser!.uid,
                ),
              ),
            );
          },
          child: Text('Back to Home'),
          style: ElevatedButton.styleFrom(
            minimumSize:
                Size(double.infinity, 50), // Full-width button at the bottom
          ),
        ),
      ),
    );
  }
}
