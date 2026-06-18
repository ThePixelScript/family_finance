import 'package:flutter/material.dart';
import 'weekly_analysis_screen.dart';
import 'customer_ledger_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Finance'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _menuButton(
              context,
              'Weekly Analysis',
              Icons.bar_chart,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WeeklyAnalysisScreen(),
                  ),
                );
              },
            ),
            _menuButton(
              context,
              'Customer Ledger',
              Icons.people,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerLedgerScreen(),
                  ),
                );
              },
            ),
            _menuButton(
              context,
              'Reports',
              Icons.description,
              () {},
            ),
            _menuButton(
              context,
              'Settings',
              Icons.settings,
              () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      width: double.infinity,
      height: 70,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}