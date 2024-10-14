import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:helth_management/form/labTestAoinment.dart';
import 'package:intl/intl.dart';

class HealthLabTestList extends StatefulWidget {
  const HealthLabTestList({super.key});

  @override
  _HealthLabTestListState createState() => _HealthLabTestListState();
}

class _HealthLabTestListState extends State<HealthLabTestList> {
  final List<Map<String, dynamic>> _labTests = [
    {'name': 'Blood Test', 'price': 50, 'rating': 4.5, 'reportTime': '6 hours'},
    {'name': 'Urine Test', 'price': 40, 'rating': 4.2, 'reportTime': '4 hours'},
    {'name': 'X-ray', 'price': 100, 'rating': 4.8, 'reportTime': '8 hours'},
    {'name': 'MRI Scan', 'price': 300, 'rating': 4.9, 'reportTime': '24 hours'},
    {'name': 'ECG', 'price': 80, 'rating': 4.6, 'reportTime': '2 hours'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Lab Tests'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: _labTests.length,
          itemBuilder: (context, index) {
            final labTest = _labTests[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: ListTile(
                title: Text(labTest['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text(
                    'Price: ${labTest['price']} Taka\nReport Time: ${labTest['reportTime']}',
                    style: const TextStyle(fontSize: 14)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    Text(labTest['rating'].toString(),
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LabTestAppointment(
                        labTestName: labTest['name'],
                        price:
                            double.tryParse(labTest['price'].toString()) ?? 100,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
