import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:math';
import 'package:helth_management/constants/email_service.dart';
import 'package:helth_management/constants/toast_services.dart';
import 'package:helth_management/screens/LoginPage.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ToastService _toastService = ToastService();
  String? generatedOtp;

  @override
  void initState() {
    super.initState();
    _sendEmailOtp(); // Automatically send OTP when screen is opened
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "OTP Verification",
          style: TextStyle(color: Color(0xFF757575)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                "OTP Verification",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "OTP verification code has been sent to ${widget.email}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF757575)),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              OtpForm(
                otpController: _otpController,
                formKey: _formKey,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              ElevatedButton(
                onPressed: _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7643),
                  shape: const StadiumBorder(),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  "Verify OTP",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: _sendEmailOtp,
                child: const Text(
                  "Resend OTP Code",
                  style: TextStyle(color: Color(0xFF757575)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      try {
        EasyLoading.show(status: 'Verifying OTP...');
        print(_otpController.text);
        print(generatedOtp);

        if (_otpController.text == generatedOtp) {
          EasyLoading.dismiss();
          _toastService.showSuccessToast(context, 'OTP Verified Successfully!');

          // Navigate to the next screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        } else {
          EasyLoading.dismiss();
          _toastService.showErrorToast(
              context, 'Invalid OTP. Please try again.');
        }
      } catch (e) {
        EasyLoading.dismiss();
        _toastService.showErrorToast(context, 'Error during verification.');
      }
    }
  }

  Future<void> _sendEmailOtp() async {
    try {
      _otpController.text = '';
      setState(() {});
      generatedOtp = _generateOtp();
      print('Generated OTP: $generatedOtp');
      EasyLoading.show(status: 'Sending OTP...');
      await EmailService().sendOtpEmail(widget.email, generatedOtp!);
      EasyLoading.dismiss();
      _toastService.showInfoToast(context, 'OTP sent to ${widget.email}');
    } catch (e) {
      EasyLoading.dismiss();
      _toastService.showErrorToast(context, 'Error sending OTP.');
    }
  }

  String _generateOtp() {
    return generateOtpRandom();
  }
}

class OtpForm extends StatelessWidget {
  final TextEditingController otpController;
  final GlobalKey<FormState> formKey;

  const OtpForm({
    super.key,
    required this.otpController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          OtpTextField(controller: otpController, index: 0),
          OtpTextField(controller: otpController, index: 1),
          OtpTextField(controller: otpController, index: 2),
          OtpTextField(controller: otpController, index: 3),
        ],
      ),
    );
  }
}

class OtpTextField extends StatelessWidget {
  final TextEditingController controller;
  final int index;

  const OtpTextField({
    super.key,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: 64,
      child: TextFormField(
        onSaved: (pin) {},
        onChanged: (pin) {
          if (pin.length == 1 && index < 3) {
            FocusScope.of(context).nextFocus();
          }
          // Updating controller text as a whole
          controller.text = controller.text + pin;
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          hintText: "",
          border: OutlineInputBorder(),
        ),
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}

String generateOtpRandom() {
  final random = Random();
  return (1000 + random.nextInt(9000)).toString(); // 4-digit OTP
}
