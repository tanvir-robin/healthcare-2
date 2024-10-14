import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:io'; // Required for File

class EmailService {
  final String username = 'tanvirrobin0@gmail.com';
  final String password = 'fkvawdrjzgnklheb';

  // Method to send OTP email
  Future<void> sendOtpEmail(String receiverEmail, String otp) async {
    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      port: 465,
      ssl: true,
      username: username,
      password: password,
    );

    final message = Message()
      ..from = Address(username, 'Health Care')
      ..recipients.add(receiverEmail)
      ..subject = 'Your OTP Code'
      ..html = '''
    <div style="font-family: Helvetica,Arial,sans-serif;min-width:1000px;overflow:auto;line-height:2">
      <div style="margin:50px auto;width:70%;padding:20px 0">
        <div style="border-bottom:1px solid #eee">
          <a href="" style="font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">Health Care</a>
        </div>
        <p style="font-size:1.1em">Hi,</p>
        <p>Thank you for choosing Health Care. Use the following OTP to complete your Sign Up procedures. OTP is valid for 5 minutes</p>
        <h2 style="background: #00466a;margin: 0 auto;width: max-content;padding: 0 10px;color: #fff;border-radius: 4px;">$otp</h2>
        <p style="font-size:0.9em;">Regards,<br />Health Care</p>
        <hr style="border:none;border-top:1px solid #eee" />
        <div style="float:right;padding:8px 0;color:#aaa;font-size:0.8em;line-height:1;font-weight:300">
          <p>Health Care</p>
          <p>Bangladesh</p>
        </div>
      </div>
    </div>
    ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('OTP Email sent: $sendReport');
    } on MailerException catch (e) {
      print('OTP Email not sent. \n${e.toString()}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  // New method to send invoice email with PDF attachment
  Future<void> sendInvoiceEmail(String receiverEmail, File pdfFile) async {
    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      port: 465,
      ssl: true,
      username: username,
      password: password,
    );

    // Create the email with PDF attachment
    final message = Message()
      ..from = Address(username, 'Health Care')
      ..recipients.add(receiverEmail)
      ..subject = 'Payment Success to Health Care'
      ..html = '''
      <div style="font-family: Helvetica,Arial,sans-serif;min-width:1000px;overflow:auto;line-height:2">
        <div style="margin:50px auto;width:70%;padding:20px 0">
          <div style="border-bottom:1px solid #eee">
            <a href="" style="font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">Health Care</a>
          </div>
          <p style="font-size:1.1em">Hi,</p>
          <p>Your payment to Health Care was successful. Please find your payment receipt attached as a PDF.</p>
          <p style="font-size:0.9em;">Regards,<br />Health Care</p>
          <hr style="border:none;border-top:1px solid #eee" />
          <div style="float:right;padding:8px 0;color:#aaa;font-size:0.8em;line-height:1;font-weight:300">
            <p>Health Care</p>
            <p>Dhaka, Bangladesh</p>
          </div>
        </div>
      </div>
      '''
      ..attachments.add(FileAttachment(pdfFile)); // Attach PDF file

    try {
      final sendReport = await send(message, smtpServer);
      print('Invoice Email sent: $sendReport');
    } on MailerException catch (e) {
      print('Invoice Email not sent. \n${e.toString()}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  Future<void> sendPrescriptionEmail(
      String receiverEmail, File pdfFile, String patientName) async {
    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      port: 465,
      ssl: true,
      username: username,
      password: password,
    );

    // Create the email with PDF attachment
    final message = Message()
      ..from = Address(username, 'Health Care')
      ..recipients.add(receiverEmail)
      ..subject = 'Your Prescription from Health Care'
      ..html = '''
      <div style="font-family: Helvetica,Arial,sans-serif;min-width:1000px;overflow:auto;line-height:2">
        <div style="margin:50px auto;width:70%;padding:20px 0">
          <div style="border-bottom:1px solid #eee">
            <a href="" style="font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">Health Care</a>
          </div>
          <p style="font-size:1.1em">Hi $patientName,</p>
          <p>Your prescription is attached as a PDF. Please review it and follow the prescribed instructions.</p>
          <p style="font-size:0.9em;">Regards,<br />Health Care</p>
          <hr style="border:none;border-top:1px solid #eee" />
          <div style="float:right;padding:8px 0;color:#aaa;font-size:0.8em;line-height:1;font-weight:300">
            <p>Health Care</p>
            <p>Dhaka, Bangladesh</p>
          </div>
        </div>
      </div>
      '''
      ..attachments.add(FileAttachment(pdfFile)); // Attach PDF file

    try {
      final sendReport = await send(message, smtpServer);
      print('Prescription Email sent: $sendReport');
    } on MailerException catch (e) {
      print('Prescription Email not sent. \n${e.toString()}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  // New method to send appointment confirmation email
  Future<void> sendAppointmentConfirmationEmail(String receiverEmail) async {
    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      port: 465,
      ssl: true,
      username: username,
      password: password,
    );

    // Create the confirmation email
    final message = Message()
      ..from = Address(username, 'Health Care')
      ..recipients.add(receiverEmail)
      ..subject = 'Appointment Confirmation'
      ..html = '''
      <div style="font-family: Helvetica,Arial,sans-serif;min-width:1000px;overflow:auto;line-height:2">
        <div style="margin:50px auto;width:70%;padding:20px 0">
          <div style="border-bottom:1px solid #eee">
            <a href="" style="font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">Health Care</a>
          </div>
          <p style="font-size:1.1em">Dear Valued Patient,</p>
          <p>We are pleased to inform you that your appointment has been booked successfully.</p>
          <p>Thank you for choosing Health Care. We look forward to seeing you!</p>
          <p>If you have any questions or need to reschedule, please don't hesitate to contact us.</p>
          <p style="font-size:0.9em;">Regards,<br />Health Care</p>
          <hr style="border:none;border-top:1px solid #eee" />
          <div style="float:right;padding:8px 0;color:#aaa;font-size:0.8em;line-height:1;font-weight:300">
            <p>Health Care</p>
            <p>Dhaka, Bangladesh</p>
          </div>
        </div>
      </div>
      ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Appointment Confirmation Email sent: $sendReport');
    } on MailerException catch (e) {
      print('Appointment Confirmation Email not sent. \n${e.toString()}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
