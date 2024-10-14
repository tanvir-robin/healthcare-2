import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildMissionVision(),
            const SizedBox(height: 20),
            _buildValues(),
            const SizedBox(height: 20),
            _buildServices(),
            const SizedBox(height: 20),
            _buildContact(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome to Healthcare Ltd.',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your trusted healthcare partner in Bangladesh.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const Divider(thickness: 2, color: Colors.teal),
      ],
    );
  }

  Widget _buildMissionVision() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Our Mission & Vision',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(FontAwesomeIcons.handsHelping, color: Colors.teal),
            const SizedBox(width: 8),
            Expanded(
              child: const Text(
                'To provide compassionate healthcare for a healthier community.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(FontAwesomeIcons.eye, color: Colors.teal),
            const SizedBox(width: 8),
            Expanded(
              child: const Text(
                'To be the leading provider of quality healthcare in Bangladesh.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildValues() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Our Values',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          '• Compassion\n'
          '• Integrity\n'
          '• Excellence\n'
          '• Collaboration\n'
          '• Innovation',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Our Services',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          '• General Health Check-ups\n'
          '• Specialist Consultations\n'
          '• Diagnostic Services\n'
          '• Emergency Care\n'
          '• Health Education Programs',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Us',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Email: contact@healthcare.com\n'
          'Phone: +88 0123 456 7890\n'
          'Address: 123 Healthcare St, Barisal, Bangladesh.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
