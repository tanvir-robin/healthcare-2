import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

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
                      const SizedBox(height: 10),
                      if (appointment.containsKey('report_pdf'))
                        ElevatedButton(
                          onPressed: () {
                            _viewPrescription(appointment['report_pdf']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            'View Prescription',
                            style: TextStyle(color: Colors.white),
                          ),
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

  Future<void> _viewPrescription(String pdfUrl) async {
    try {
      // Show loading indicator
      EasyLoading.show(status: 'Getting your pescription...');

      // Download the PDF file using the http package
      var response = await http.get(Uri.parse(pdfUrl));

      if (response.statusCode == 200) {
        // Get the application's documents directory
        var dir = await getApplicationDocumentsDirectory();
        String savePath = '${dir.path}/prescription.pdf';

        // Save the file
        File file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);

        // Open the downloaded PDF file
        await OpenFile.open(savePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error downloading prescription: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening prescription: $e')),
      );
    } finally {
      // Hide loading indicator
      EasyLoading.dismiss();
    }
  }
}
