import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helth_management/constants/colors.dart';
import 'package:helth_management/services/NetworkHelper.dart';

import 'package:http/http.dart' as http;

class History extends StatefulWidget {
  final String userId;

  const History({super.key, required this.userId});

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  bool _loading = false;
  late List _history;
  late double width;
  late double height;

  @override
  void initState() {
    _getHistory();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

// get the appointments list
  Future<http.Response> _getHistory() async {
    setState(() {
      _loading = true;
    });

    final http.Response response = await Network().postData(
        {'user_id': widget.userId, 'list_type': 'history'}, '/getLists.php');

    print('response ---- ${jsonDecode(response.body)}');

    setState(() {
      _loading = false;
      var res = jsonDecode(response.body);
      setState(() {
        _history = res['historyList'];
      });
    });

    print(_history);

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
        title: const Text('History'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              height: height,
              child: _history.isNotEmpty
                  ? SingleChildScrollView(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          _getHistory();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          height: height * 0.85,
                          width: double.infinity,
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: _history.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    _viewAppointmentDialog(
                                        context, _history[index]);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 10, 20, 6),
                                    margin: const EdgeInsets.fromLTRB(
                                        20, 10, 20, 10),
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
                                              _history[index]['full_name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2,
                                                      horizontal: 5),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: _history[index][
                                                              'appointment_status'] ==
                                                          'COMPLETED'
                                                      ? Colors.grey[600]
                                                      : _history[index][
                                                                  'appointment_status'] ==
                                                              'CANCELLED'
                                                          ? Colors
                                                              .redAccent[100]
                                                          : Colors.red[600]),
                                              child: Text(
                                                _history[index]
                                                    ['appointment_status'],
                                                style: const TextStyle(
                                                    color: colorWhite,
                                                    fontWeight:
                                                        FontWeight.w500),
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
                                                _history[index]['description'],
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
                                            (_history[index]['date'] == null ||
                                                    _history[index]['time'] ==
                                                        null)
                                                ? const Text(
                                                    'N/A',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  )
                                                : Text(
                                                    '${_history[index]['date']}  ${_history[index]['time']}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text('No appointment data found!'),
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
