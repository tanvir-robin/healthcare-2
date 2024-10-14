import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:get/get.dart';
import 'package:helth_management/screens/payment/payment_failed.dart';
import 'package:helth_management/screens/payment/payment_success.dart';

class LabTestPaymentScreen extends StatelessWidget {
  final Map<String, dynamic> labTestDetails;
  final String labTestId;

  const LabTestPaymentScreen(
      {Key? key, required this.labTestDetails, required this.labTestId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paymentAmount = labTestDetails['price'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Test Payment'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${labTestDetails['name']}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('Phone: ${labTestDetails['phone']}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 5),
                    Text('Sample ID: ${labTestDetails['sample_id']}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 5),
                    Text(
                        'Appointment Date: ${labTestDetails['appointment_date']}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 5),
                    Text(
                        'Report Delivery Date: ${labTestDetails['report_delivery_date']}',
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'BDT ${paymentAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          Sslcommerz sslcommerz = Sslcommerz(
                            initializer: SSLCommerzInitialization(
                              multi_card_name: "visa,master,bkash",
                              currency: SSLCurrencyType.BDT,
                              product_category: "Health",
                              sdkType: SSLCSdkType.TESTBOX,
                              store_id: "algor670ab401dbbcc",
                              store_passwd: "algor670ab401dbbcc@ssl",
                              total_amount: paymentAmount,
                              tran_id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                            ),
                          );

                          // Perform the payment
                          final res = await sslcommerz.payNow();

                          // Get current user data
                          User? currentUser = FirebaseAuth.instance.currentUser;

                          // Transaction data to save in Firestore
                          Map<String, dynamic> transactionData = {
                            'root': 'lab-tests',
                            'user': currentUser!.uid,
                            'email': currentUser.email,
                            'time': Timestamp.now(),
                            'status': res.status,
                            'tran_id': res.tranId,
                            'amount': res.amount,
                            'card_type': res.cardType,
                            'bank_tran_id': res.bankTranId,
                          };

                          // Save the transaction to Firestore
                          final transDoc = await FirebaseFirestore.instance
                              .collection('transactions')
                              .add(transactionData);

                          if (res.status == 'VALID') {
                            // Update lab test payment status
                            await FirebaseFirestore.instance
                                .collection('lab-test')
                                .doc(labTestId)
                                .update({
                              'payment_status': 'paid',
                              'transaction_doc': transDoc.id,
                            });

                            // Navigate to Payment Success screen
                            Get.to(() => PaymentSuccessScreen());
                          } else {
                            // Navigate to Payment Failed screen
                            Get.to(() => PaymentFailedScreen());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 40),
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Pay with SSLCommerz',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
