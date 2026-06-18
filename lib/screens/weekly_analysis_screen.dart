import 'package:flutter/material.dart';

import '../models/app_data.dart';
import '../models/week.dart';
import 'week_ledger_screen.dart';

class WeeklyAnalysisScreen extends StatefulWidget {
  const WeeklyAnalysisScreen({super.key});

  @override
  State<WeeklyAnalysisScreen> createState() =>
      _WeeklyAnalysisScreenState();
}

class _WeeklyAnalysisScreenState
    extends State<WeeklyAnalysisScreen> {
  void _createWeek() {
    final startController =
        TextEditingController();

    final endController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Week'),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              TextField(
                controller:
                    startController,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Start Date',
                ),
              ),
              TextField(
                controller:
                    endController,
                decoration:
                    const InputDecoration(
                  labelText:
                      'End Date',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (startController
                        .text
                        .trim()
                        .isEmpty ||
                    endController
                        .text
                        .trim()
                        .isEmpty) {
                  return;
                }

                AppData.weeks.add(
                  Week(
                    id: AppData
                            .weeks
                            .length +
                        1,
                    startDate:
                        startController
                            .text,
                    endDate:
                        endController
                            .text,
                  ),
                );

                setState(() {});

                Navigator.pop(
                  context,
                );
              },
              child: const Text(
                'Save',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Weekly Analysis'),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _createWeek,
        icon: const Icon(Icons.add),
        label:
            const Text('Create Week'),
      ),
      body: ListView.builder(
        padding:
            const EdgeInsets.all(16),
        itemCount:
            AppData.weeks.length,
        itemBuilder:
            (context, index) {
          final week =
              AppData.weeks[index];

          return Card(
            child: ListTile(
              leading: const Icon(
                Icons.calendar_month,
              ),
              title:
                  Text(week.title),
              subtitle: const Text(
                'Tap to open ledger',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const WeekLedgerScreen(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}