import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:helth_management/constants/colors.dart';
import 'package:helth_management/constants/images.dart';
import 'package:helth_management/screens/LoginPage.dart';
import 'package:helth_management/screens/otp_screen.dart';

import 'package:helth_management/widgets/MyButton.dart';
import 'package:helth_management/widgets/MyTextField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late double width;
  late double height;
  final bool _loading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to register the user
  Future<void> _register() async {
    // setState(() {
    //   _loading = true;
    // });
    EasyLoading.show(status: 'Creating Account...');

    try {
      // Sign up user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Save additional user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'full_name': _nameController.text,
          'username': _usernameController.text,
          'email': _emailController.text,
          'contact': _contactController.text,
          'address': _addressController.text,
        });

        // Navigate to OTP verification screen with user email
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                VerificationScreen(email: _emailController.text),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: e.message ?? 'Error occurred during sign up',
        backgroundColor: Colors.red[600],
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  String? validateEmail(String value) {
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(pattern);

    if (value.isEmpty) {
      return 'Email address is required';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validateMobile(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(pattern);

    if (value.isEmpty) {
      return 'Mobile number is required';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 50, 10, 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'REGISTER',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 28),
                          ),
                          SvgPicture.asset(
                            signup_image,
                            height: width * 0.50,
                          ),
                          const SizedBox(height: 10),

                          // Full name
                          MyTextField(
                            controller: _nameController,
                            hint: "Name",
                            icon: Icons.home,
                            validation: (val) {
                              if (val.isEmpty) {
                                return "Name is required";
                              }
                              return null;
                            },
                          ),

                          // Username
                          MyTextField(
                            controller: _usernameController,
                            hint: "Username",
                            icon: Icons.home,
                            validation: (val) {
                              if (val.isEmpty) {
                                return "Username is required";
                              }
                              return null;
                            },
                          ),

                          // Email
                          MyTextField(
                            controller: _emailController,
                            hint: "Email",
                            isEmail: true,
                            icon: Icons.contact_mail,
                            validation: (val) {
                              return validateEmail(val);
                            },
                          ),

                          // Contact
                          MyTextField(
                            controller: _contactController,
                            hint: "Contact",
                            isNumber: true,
                            maxLength: 10,
                            icon: Icons.contact_phone,
                            validation: (val) {
                              return validateMobile(val);
                            },
                          ),

                          // Address
                          MyTextField(
                            controller: _addressController,
                            hint: "Address",
                            isMultiline: true,
                            maxLines: 3,
                            icon: Icons.home,
                            validation: (val) {
                              if (val.isEmpty) {
                                return "Address is required";
                              }
                              return null;
                            },
                          ),

                          // Password
                          MyTextField(
                            controller: _passwordController,
                            hint: "Password",
                            isPassword: true,
                            isSecure: true,
                            icon: Icons.home,
                            validation: (val) {
                              if (val.isEmpty) {
                                return "Password is required";
                              }
                              return null;
                            },
                          ),

                          // Sign Up Button
                          GestureDetector(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                _register();
                              }
                            },
                            child: const MyButton(
                              text: 'SIGNUP',
                              btnColor: primaryColor,
                              btnRadius: 8,
                            ),
                          ),

                          // Link to Login page
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account?',
                                style: TextStyle(
                                    color: primaryColor, fontSize: 16),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const LoginPage()));
                                },
                                child: const Text(
                                  'Log in',
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
