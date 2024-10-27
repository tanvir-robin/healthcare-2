import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:helth_management/screens/payment/payment_lab_test.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class LabTestAppointment extends StatefulWidget {
  final String labTestName;
  final double price;

  const LabTestAppointment({
    Key? key,
    required this.labTestName,
    required this.price,
  }) : super(key: key);

  @override
  State<LabTestAppointment> createState() => _LabTestAppointmentState();
}

class _LabTestAppointmentState extends State<LabTestAppointment> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _appointmentDateTimeController =
      TextEditingController();
  String _sampleId = '';
  String _reportSubmissionDate = '';

  @override
  void initState() {
    super.initState();
    _generateSampleId(); // Automatically generate sample ID
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment for ${widget.labTestName}'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildLabel('Price: ${widget.price} Taka'),
              const SizedBox(height: 20),
              _buildTextField(
                  _nameController, 'Name', 'Please enter your name'),
              const SizedBox(height: 10),
              _buildDisabledTextField('Sample ID: $_sampleId'),
              const SizedBox(height: 10),
              _buildTextField(_phoneController, 'Phone',
                  'Please enter your phone number', TextInputType.phone),
              const SizedBox(height: 10),
              _buildDateTimePicker(),
              const SizedBox(height: 20),
              Text(
                'Report Delivery Date: $_reportSubmissionDate',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveLabTestAppointment();
                  }
                },
                child: const Text('Submit Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Generates a random sample ID
  void _generateSampleId() {
    final random = Random();
    final sampleId = 'SAMPLE-${random.nextInt(999999)}';
    setState(() {
      _sampleId = sampleId;
    });
  }

  // Builds a text field with better style
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String validationMessage, [
    TextInputType inputType = TextInputType.text,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: (value) {
        if (value!.isEmpty) {
          return validationMessage;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
    );
  }

  // Builds a disabled text field for sample ID
  Widget _buildDisabledTextField(String label) {
    return TextFormField(
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
    );
  }

  // Builds a label for price
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // Builds date and time picker
  Widget _buildDateTimePicker() {
    return TextFormField(
      controller: _appointmentDateTimeController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Sample Giving Schedule',
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                DateTime appointmentDateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
                setState(() {
                  _appointmentDateTimeController.text =
                      DateFormat('yyyy-MM-dd hh:mm a')
                          .format(appointmentDateTime);
                  _calculateReportSubmissionDate(appointmentDateTime);
                });
              }
            }
          },
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please select appointment date & time';
        }
        return null;
      },
    );
  }

  // Calculates report submission date based on test type
  void _calculateReportSubmissionDate(DateTime appointmentDate) {
    int hoursToAdd = 0;
    if (widget.labTestName == 'X-ray') {
      hoursToAdd = 8;
    } else if (widget.labTestName == 'MRI Scan') {
      hoursToAdd = 24;
    } else {
      hoursToAdd = 6; // Default report submission time for other tests
    }
    DateTime reportSubmissionDate =
        appointmentDate.add(Duration(hours: hoursToAdd));
    setState(() {
      _reportSubmissionDate =
          DateFormat('d MMM, hh:mm a').format(reportSubmissionDate);
    });
  }

  // Saves lab test appointment to Firestore
  // Saves lab test appointment to Firestore
  void _saveLabTestAppointment() async {
    EasyLoading.show(status: 'Saving Appointment...');
    try {
      // Save the lab test appointment to Firestore
      DocumentReference appointmentRef =
          await FirebaseFirestore.instance.collection('lab-test').add({
        'created_at': FieldValue.serverTimestamp(),
        'payment_status': 'unpaid', // Payment system can be integrated later
        'patient_id': FirebaseAuth.instance.currentUser!.uid, // User ID
        'name': _nameController.text,
        'sample_id': _sampleId,
        'phone': _phoneController.text,
        'appointment_date': _appointmentDateTimeController.text,
        'report_delivery_date': _reportSubmissionDate,
        'lab_test_name': widget.labTestName,
        'price': widget.price,
      });

      EasyLoading.showSuccess('Appointment Saved');

      // Prepare lab test details to pass to the payment screen
      Map<String, dynamic> labTestDetails = {
        'name': _nameController.text,
        'sample_id': _sampleId,
        'phone': _phoneController.text,
        'appointment_date': _appointmentDateTimeController.text,
        'report_delivery_date': _reportSubmissionDate,
        'price': widget.price,
      };

      // Navigate to payment screen with lab test details
      Get.to(() => LabTestPaymentScreen(
            labTestDetails: labTestDetails,
            labTestId:
                appointmentRef.id, // Pass the document ID for future reference
          ));
    } catch (e) {
      EasyLoading.showError('Error: ${e.toString()}');
    }
  }
}
