import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helth_management/screens/Dashboard.dart';
import 'package:helth_management/screens/LoginPage.dart';
import 'package:helth_management/screens/all_appointments.dart';

class PaymentFailedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 120,
            ),
            SizedBox(height: 20),
            Text(
              'Payment Failed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: () {
            MaterialPageRoute(
              builder: (BuildContext context) => Dashboard(
                name: globalUserData?['full_name'] ?? 'User',
                userId: FirebaseAuth.instance.currentUser!.uid,
              ),
            );
          },
          child: Text('Retry'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            backgroundColor: Colors.red,
          ),
        ),
      ),
    );
  }
}
