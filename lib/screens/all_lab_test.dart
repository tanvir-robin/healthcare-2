import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helth_management/screens/report_view.dart';

class LabTestAppointmentsList extends StatelessWidget {
  const LabTestAppointmentsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Lab Test Appointments',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('lab-test')
            .where('patient_id',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('created_at', descending: true)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Lab Test Appointments Found'));
          }

          final labTests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: labTests.length,
            itemBuilder: (context, index) {
              final labTest = labTests[index].data() as Map<String, dynamic>;
              final labTestId = labTests[index].id;

              // Get details from lab test document
              final testName = labTest['lab_test_name'] ?? 'Unknown';
              final name = labTest['name'] ?? 'N/A';
              final phone = labTest['phone'] ?? 'N/A';
              final sampleId = labTest['sample_id'] ?? 'N/A';
              final appointmentDate = labTest['appointment_date'] ?? 'N/A';
              final reportDeliveryDate =
                  labTest['report_delivery_date'] ?? 'N/A';
              final paymentStatus = labTest['payment_status'] ?? 'unpaid';
              final report = labTest['report'];

              // Determine test status
              String testStatus;
              if (report != null) {
                testStatus = 'Completed';
              } else if (paymentStatus == 'paid') {
                testStatus = 'Processing';
              } else {
                testStatus = 'Pending';
              }

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleRow('Test Name:', testName, Icons.science),
                        const SizedBox(height: 10),
                        _buildDetailRow('Name:', name),
                        _buildDetailRow('Phone:', phone),
                        _buildDetailRow('Sample ID:', sampleId),
                        _buildDetailRow('Appointment Date:', appointmentDate),
                        _buildDetailRow(
                            'Report Delivery Date:', reportDeliveryDate),
                        const Divider(thickness: 1),
                        _buildStatusRow(
                          'Payment Status:',
                          paymentStatus == 'paid' ? 'Paid' : 'Unpaid',
                          paymentStatus == 'paid'
                              ? Icons.check
                              : Icons.money_off,
                          paymentStatus == 'paid' ? Colors.green : Colors.red,
                        ),
                        _buildStatusRow(
                          'Test Status:',
                          testStatus,
                          testStatus == 'Completed'
                              ? Icons.check_circle_outline
                              : Icons.hourglass_empty,
                          testStatus == 'Completed'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(height: 10),
                        if (report !=
                            null) // Show "View Report" button if report exists
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(() => ReportViewPage(
                                      labTestId: labTestId,
                                    ));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'View Report',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper function to build detail rows for UI
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 5),
          Flexible(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  // Helper function for title row with icon
  Widget _buildTitleRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal),
        const SizedBox(width: 10),
        Text(
          '$label $value',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  // Helper function to build status rows for UI with icons and color
  Widget _buildStatusRow(
      String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
