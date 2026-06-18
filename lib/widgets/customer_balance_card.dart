import 'package:flutter/material.dart';

class CustomerBalanceCard
    extends StatelessWidget {

  final double balance;

  const CustomerBalanceCard({
    super.key,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {

    final bool isPositive =
        balance >= 0;

    return Card(
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text(
              isPositive
                  ? 'YOU WILL GET'
                  : 'YOU WILL GIVE',
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '₹${balance.abs().toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 30,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}