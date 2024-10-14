import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:helth_management/screens/payment/paymnent_screen.dart';

class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  _AppointmentListPageState createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('appointments')
            .where('patient_id',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment =
                  appointments[index].data() as Map<String, dynamic>;
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${appointment['name']}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Email: ${appointment['email']}',
                          style: const TextStyle(fontSize: 14)),
                      Text('Phone: ${appointment['phone']}',
                          style: const TextStyle(fontSize: 14)),
                      Text('Doctor: ${appointment['doctor']}',
                          style: const TextStyle(fontSize: 14)),
                      Text(
                          'Appointment Date: ${appointment['appointmentDate']}',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment Status: ${appointment['payment_status']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                          if (appointment['payment_status'] == 'unpaid')
                            ElevatedButton(
                              onPressed: () {
                                _payNow(appointment, appointments[index].id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                              ),
                              child: const Text(
                                'Pay Now',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _payNow(Map<String, dynamic> appointment, String appointmentId) {
    // Navigate to the payment screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          appointmentDetails: appointment,
          appointmentId: appointmentId,
        ),
      ),
    );
  }
}
