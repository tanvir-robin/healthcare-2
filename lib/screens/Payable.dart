import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:helth_management/constants/colors.dart';
import 'package:helth_management/services/NetworkHelper.dart';

import 'package:http/http.dart' as http;

class Payable extends StatefulWidget {
  final String userId;

  const Payable({super.key, required this.userId});

  @override
  _PayableState createState() => _PayableState();
}

class _PayableState extends State<Payable> {
  bool _loading = false;
  late List _payableAppointments;
  late double width;
  late double height;
  String dropdownValue = 'Pay';

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    _getPayableAppointments();
    super.initState();
    // StripeService.init();
  }

  @override
  void dispose() {
    super.dispose();
  }

// get the payable appointments list
  Future<http.Response> _getPayableAppointments() async {
    setState(() {
      _loading = true;
    });

    final http.Response response = await Network().postData(
        {'user_id': widget.userId, 'list_type': 'payable'}, '/getLists.php');

    print('response ---- ${jsonDecode(response.body)}');

    setState(() {
      _loading = false;
      var res = jsonDecode(response.body);
      setState(() {
        _payableAppointments = res['payableList'];
      });
    });

    print(_payableAppointments);

    return response;
  }

  // cancelling an appointment
  Future<http.Response> _cancelAppointment(appointmentId) async {
    setState(() {
      _loading = true;
    });

    final http.Response response = await Network().postData({
      'appointment_id': appointmentId.toString(),
    }, '/cancelAppointment.php');

    print('response ---- ${jsonDecode(response.body)}');

    setState(() {
      _loading = false;
    });

    return response;
  }

  // make poyment
  // Future<StripeTransactionResponse> _makePayment() async {
  //   setState(() {
  //     _loading = true;
  //   });

  //   final response = await StripeService.payWithNewCard(
  //       amount: '500000', currency: 'lkr', paymentFor: 'APPOINTMENT');

  //   setState(() {
  //     _loading = false;
  //   });

  //   return response;
  // }

  // marking as paid
  Future<http.Response> _markAsPaid(appointmentId, stripeCustomerId) async {
    setState(() {
      _loading = true;
    });

    final http.Response response = await Network().postData({
      'patient_id': widget.userId.toString(),
      'appointment_id': appointmentId.toString(),
      'payment_for': 'APPOINTMENT',
      'amount': '500000',
      'stripe_customer_id': stripeCustomerId
    }, '/charge.php');

    print('response ---- ${jsonDecode(response.body)}');

    setState(() {
      _loading = false;
    });

    return response;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Payable Appointments'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              height: height,
              child: _payableAppointments.isNotEmpty
                  ? SingleChildScrollView(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          _getPayableAppointments();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          height: height * 0.85,
                          width: double.infinity,
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: _payableAppointments.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 6),
                                  margin:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  width: width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: colorWhite,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: const Offset(0, 3)),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _payableAppointments[index]
                                                ['full_name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2, horizontal: 5),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: _payableAppointments[index][
                                                            'appointment_status'] ==
                                                        'PENDING'
                                                    ? Colors.orange
                                                    : _payableAppointments[index][
                                                                'appointment_status'] ==
                                                            'ACCEPTED'
                                                        ? Colors.green
                                                        : _payableAppointments[index]
                                                                    [
                                                                    'appointment_status'] ==
                                                                'PAID'
                                                            ? Colors.blue[700]
                                                            : _payableAppointments[index]
                                                                        [
                                                                        'appointment_status'] ==
                                                                    'COMPLETED'
                                                                ? Colors
                                                                    .grey[600]
                                                                : _payableAppointments[index]
                                                                            ['appointment_status'] ==
                                                                        'CANCELLED'
                                                                    ? Colors.redAccent[100]
                                                                    : Colors.red[600]),
                                            child: Text(
                                              _payableAppointments[index]
                                                  ['appointment_status'],
                                              style: const TextStyle(
                                                  color: colorWhite,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: width - 80,
                                            height: 50,
                                            child: Text(
                                              _payableAppointments[index]
                                                  ['description'],
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            'Appointment: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          (_payableAppointments[index]
                                                          ['date'] ==
                                                      null ||
                                                  _payableAppointments[index]
                                                          ['time'] ==
                                                      null)
                                              ? const Text(
                                                  'N/A',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                )
                                              : Text(
                                                  '${_payableAppointments[index]['date']}  ${_payableAppointments[index]['time']}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: DropdownButton<String>(
                                              isDense: true,
                                              isExpanded: true,
                                              icon: const Icon(
                                                Icons.more_horiz,
                                              ),
                                              underline: Container(
                                                height: 0,
                                                color: Colors.deepPurpleAccent,
                                              ),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  dropdownValue = newValue!;
                                                });
                                              },
                                              items: <String>[
                                                'Pay',
                                                'View',
                                                'Cancel'
                                              ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                  onTap: () {
                                                    print(value);
                                                    print(_payableAppointments[
                                                        index]);

                                                    if (value == 'View') {
                                                      _viewAppointmentDialog(
                                                          context,
                                                          _payableAppointments[
                                                              index]);
                                                    } else if (value ==
                                                        'Cancel') {
                                                      _cancelAppointment(
                                                              _payableAppointments[
                                                                      index][
                                                                  'appointment_id'])
                                                          .then((value) {
                                                        var res = jsonDecode(
                                                            value.body);

                                                        if (res['error'] ==
                                                            true) {
                                                          Fluttertoast.showToast(
                                                              msg: res[
                                                                  'message'],
                                                              backgroundColor:
                                                                  Colors
                                                                      .red[600],
                                                              textColor:
                                                                  Colors.white,
                                                              toastLength: Toast
                                                                  .LENGTH_LONG);
                                                        } else {
                                                          Fluttertoast.showToast(
                                                                  msg: res[
                                                                      'message'],
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  toastLength: Toast
                                                                      .LENGTH_LONG)
                                                              .then((value) {
                                                            _getPayableAppointments();
                                                          });
                                                        }
                                                      });
                                                    } else if (value == 'Pay') {
                                                      //   _makePayment()
                                                      //       .then((value) {
                                                      //     if (value.success ==
                                                      //         true) {
                                                      //       _markAsPaid(
                                                      //               _payableAppointments[
                                                      //                       index]
                                                      //                   [
                                                      //                   'appointment_id'],
                                                      //               value
                                                      //                   .paymentId)
                                                      //           .then((val) {
                                                      //         var res =
                                                      //             jsonDecode(
                                                      //                 val.body);
                                                      //         if (res['error'] ==
                                                      //             false) {
                                                      //           Fluttertoast.showToast(
                                                      //                   msg: res[
                                                      //                       'message'],
                                                      //                   backgroundColor:
                                                      //                       Colors
                                                      //                           .green,
                                                      //                   textColor:
                                                      //                       colorWhite,
                                                      //                   toastLength:
                                                      //                       Toast
                                                      //                           .LENGTH_LONG)
                                                      //               .whenComplete(
                                                      //                   () {
                                                      //             _getPayableAppointments();
                                                      //           });
                                                      //         } else {
                                                      //           Fluttertoast.showToast(
                                                      //               msg: res[
                                                      //                   'message'],
                                                      //               backgroundColor:
                                                      //                   errorColor,
                                                      //               textColor:
                                                      //                   colorWhite,
                                                      //               toastLength: Toast
                                                      //                   .LENGTH_LONG);
                                                      //         }
                                                      //       });
                                                      //     } else {
                                                      //       Fluttertoast.showToast(
                                                      //           msg:
                                                      //               value.message,
                                                      //           backgroundColor:
                                                      //               errorColor,
                                                      //           textColor:
                                                      //               colorWhite,
                                                      //           toastLength: Toast
                                                      //               .LENGTH_LONG);
                                                      //     }
                                                      //   });
                                                    }
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text('No payable appointments found!'),
                    ),
            ),
    );
  }

  // view appointment details dialog
  Future<Future> _viewAppointmentDialog(context, appointment) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
              ),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    height: 70,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text('Appointment Details',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: colorWhite),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Form(
                      key: _formKey,
                      child: SizedBox(
                        height: 200,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Description:',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 16),
                              ),
                              Text(appointment['description']),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text(
                                    'Date: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  Text(appointment['date'] ?? 'N/A')
                                ],
                              ),
                              Row(
                                children: [
                                  const Text(
                                    'Time: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  Text(appointment['time'] ?? 'N/A')
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Comments: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 16),
                              ),
                              Text(appointment['comments'] ?? 'N/A'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 30.0,
                      width: double.infinity,
                      child: const Text(
                        'CLOSE',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
