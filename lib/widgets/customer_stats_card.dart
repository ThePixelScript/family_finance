import 'package:flutter/material.dart';

class CustomerStatsCard extends StatelessWidget {
  final double totalCredit;
  final double totalDebit;
  final double balance;
  final int transactionCount;

  const CustomerStatsCard({
    super.key,
    required this.totalCredit,
    required this.totalDebit,
    required this.balance,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            statRow(
              'Total Credit',
              '₹${totalCredit.toStringAsFixed(0)}',
            ),
            statRow(
              'Total Debit',
              '₹${totalDebit.toStringAsFixed(0)}',
            ),
            statRow(
              'Transactions',
              transactionCount.toString(),
            ),
            const Divider(),
            statRow(
              'Balance',
              '₹${balance.toStringAsFixed(0)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget statRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}