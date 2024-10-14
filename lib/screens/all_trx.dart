import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TransactionListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transactions')),
        body: const Center(
          child: Text('You need to be logged in to view your transactions.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Transactions'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('user', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching transactions.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          final transactions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction =
                  transactions[index].data() as Map<String, dynamic>;
              return TransactionCard(transaction: transaction);
            },
          );
        },
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionCard({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amount = transaction['amount'];
    final tranId = transaction['tran_id'];
    final cardType = transaction['card_type'];
    final status = transaction['status'];
    final bankTranId = transaction['bank_tran_id'];
    final time = (transaction['time'] as Timestamp).toDate();
    final formattedTime = DateFormat('dd MMMM yyyy, hh:mm a').format(time);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.payment, color: Colors.teal),
        title: Text('Amount: $amount BDT',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction ID: $tranId'),
            Text('Payment Method: $cardType'),
            Text('Bank Transaction ID: $bankTranId'),
            Text('Status: $status'),
            Text('Date: $formattedTime'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
