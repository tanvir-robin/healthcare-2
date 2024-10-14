import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class ReportViewPage extends StatelessWidget {
  final String labTestId; // Pass the ID of the lab test

  const ReportViewPage({Key? key, required this.labTestId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Test Report'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _generateAndShowPDF(context);
          },
          child: const Text('View Report PDF'),
        ),
      ),
    );
  }

  Future<void> _generateAndShowPDF(BuildContext context) async {
    // Fetch the lab test report data from Firestore
    DocumentSnapshot labTestDoc = await FirebaseFirestore.instance
        .collection('lab-test')
        .doc(labTestId)
        .get();

    if (!labTestDoc.exists || labTestDoc['report'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report not available for this test')),
      );
      return;
    }

    final labTest = labTestDoc.data() as Map<String, dynamic>;
    final reportContent = labTest['report']; // Main report content

    // Generate the PDF
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildPatientInfo(labTest),
            pw.SizedBox(height: 20),
            _buildReportDetails(labTest, reportContent),
            pw.SizedBox(height: 30),
            _buildFooter(),
          ];
        },
      ),
    );

    // Save the PDF to the device
    final outputDir = await getApplicationDocumentsDirectory();
    final filePath = '${outputDir.path}/lab_test_report_$labTestId.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open the saved PDF using open_file package
    await OpenFile.open(filePath);
  }

  // Header with centered title and design
  pw.Widget _buildHeader() {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text(
            'Healthcare Ltd.',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal,
            ),
          ),
        ),
        pw.Center(
          child: pw.Text(
            'Barisal, Bangladesh',
            style: pw.TextStyle(
              fontSize: 18,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Divider(thickness: 2, color: PdfColors.teal),
      ],
    );
  }

  // Patient Info section with background color and icon
  pw.Widget _buildPatientInfo(Map<String, dynamic> labTest) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey300,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.SizedBox(width: 5),
              pw.Text(
                'Patient Information',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text('Name: ${labTest['name']}', style: _normalTextStyle()),
          pw.Text('Phone: ${labTest['phone']}', style: _normalTextStyle()),
          pw.Text('Sample ID: ${labTest['sample_id']}',
              style: _normalTextStyle()),
          pw.Text('Appointment Date: ${labTest['appointment_date']}',
              style: _normalTextStyle()),
          pw.Text('Report Delivery Date: ${labTest['report_delivery_date']}',
              style: _normalTextStyle()),
        ],
      ),
    );
  }

  // Lab Test Details with icons and clean design
  pw.Widget _buildReportDetails(
      Map<String, dynamic> labTest, String reportContent) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.SizedBox(width: 5),
            pw.Text(
              'Lab Test Details',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Text('Test Name: ${labTest['lab_test_name']}',
            style: _normalTextStyle()),
        pw.Text('Price: ${labTest['price']} Taka', style: _normalTextStyle()),
        pw.SizedBox(height: 20),
        pw.Text(
          'Test Report',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Text(reportContent, style: _normalTextStyle()),
      ],
    );
  }

  // Footer with small note
  pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 10),
        pw.Text(
          'Note: This is a software-generated copy but authorized.',
          style: pw.TextStyle(
            fontSize: 12,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  // Helper to apply a normal text style
  pw.TextStyle _normalTextStyle() {
    return pw.TextStyle(
      fontSize: 14,
      color: PdfColors.grey800,
    );
  }
}
