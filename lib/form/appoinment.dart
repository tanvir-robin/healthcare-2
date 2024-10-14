import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helth_management/constants/email_service.dart';
import 'package:intl/intl.dart';

class AppointmentForm extends StatefulWidget {
  const AppointmentForm({super.key});
  @override
  State<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedDoctor;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _dateController.text =
              "${DateFormat.yMd().format(picked)} ${pickedTime.format(context)}";
        });
      }
    }
  }

  Future<void> _submitAppointment() async {
    if (_formKey.currentState!.validate()) {
      // Adding payment_status and amount to the appointment data
      final appointmentData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'doctor': _selectedDoctor,
        'appointmentDate': _dateController.text,
        'payment_status': 'unpaid', // Default value
        'amount': 1000,
        'patient_id': FirebaseAuth.instance.currentUser!.uid,
        'created_at': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('appointments')
          .add(appointmentData);

      await EmailService().sendAppointmentConfirmationEmail(
        FirebaseAuth.instance.currentUser!.email!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Health Appointment'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDoctor,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDoctor = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a doctor' : null,
                decoration: const InputDecoration(
                  labelText: 'Doctor',
                  labelStyle: TextStyle(color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  border: OutlineInputBorder(),
                ),
                items: <String>[
                  'Dr. Mohammad Zakir Hossain',
                  'Dr. Mahbubul Alam',
                  'Dr. Rubaiyat Haque',
                  'Dr. Tahmina Alam',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please select appointment date and time';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Appointment Date & Time',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      _selectDate(context);
                    },
                  ),
                  labelStyle: const TextStyle(color: Colors.teal),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Center(
                    child: Text(
                  'Submit Appointment',
                  style: TextStyle(color: Colors.white),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
