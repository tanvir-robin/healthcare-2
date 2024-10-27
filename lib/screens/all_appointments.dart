import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:helth_management/constants/available_doctors.dart';
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
              final doctorName = appointment['doctor'];
              final doctor = demoAvailableDoctors.firstWhere(
                (doc) => doc.name == doctorName,
              );

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(doctor.image),
                            radius: 25,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Doctor: ${doctor.name}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Appointment Date: ${appointment['appointmentDate']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Name: ${appointment['name']}',
                          style: const TextStyle(fontSize: 16)),
                      Text('Email: ${appointment['email']}',
                          style: const TextStyle(fontSize: 14)),
                      Text('Phone: ${appointment['phone']}',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment Status: ${appointment['payment_status']}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.red),
                          ),
                          if (appointment['payment_status'] == 'unpaid')
                            ElevatedButton(
                              onPressed: () =>
                                  _payNow(appointment, appointments[index].id),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal),
                              child: const Text('Pay Now',
                                  style: TextStyle(color: Colors.white)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (appointment.containsKey('report_pdf'))
                        ElevatedButton(
                          onPressed: () =>
                              _viewPrescription(appointment['report_pdf']),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          child: const Text('View Prescription',
                              style: TextStyle(color: Colors.white)),
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
      EasyLoading.show(status: 'Getting your prescription...');
      var response = await http.get(Uri.parse(pdfUrl));

      if (response.statusCode == 200) {
        var dir = await getApplicationDocumentsDirectory();
        String savePath = '${dir.path}/prescription.pdf';
        File file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
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
      EasyLoading.dismiss();
    }
  }
}
