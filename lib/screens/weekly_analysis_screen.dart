import 'package:flutter/material.dart';

import '../database/week_repository.dart';
import '../models/week.dart';
import 'week_ledger_screen.dart';

class WeeklyAnalysisScreen extends StatefulWidget {
  const WeeklyAnalysisScreen({super.key});

  @override
  State<WeeklyAnalysisScreen> createState() =>
      _WeeklyAnalysisScreenState();
}

class _WeeklyAnalysisScreenState extends State<WeeklyAnalysisScreen> {
  final WeekRepository _weekRepository = WeekRepository();
  List<Week> _weeks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshWeeks();
  }

  Future<void> _refreshWeeks() async {
    setState(() => _isLoading = true);
    final data = await _weekRepository.getWeeksWithSummaries();
    setState(() {
      _weeks = data;
      _isLoading = false;
    });
  }

  Future<void> _selectDate(
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        controller.text = picked.toString().split(' ')[0];
      });
    }
  }

  void _createWeek() {
    final startController = TextEditingController();
    final endController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create Week'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: startController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(startController),
              ),
              TextField(
                controller: endController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(endController),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (startController.text.trim().isEmpty ||
                    endController.text.trim().isEmpty) {
                  return;
                }

                // Capture navigator state before async gap to satisfy compiler sync constraints
                final navigator = Navigator.of(dialogContext);

                await _weekRepository.insertWeek(
                  Week(
                    startDate: startController.text,
                    endDate: endController.text,
                  ),
                );

                navigator.pop();
                _refreshWeeks();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(Week week) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Week?'),
        content: Text(
          'Are you sure you want to delete week ${week.title}? This will delete all associated ledger entries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              if (week.id != null) {
                await _weekRepository.deleteWeek(week.id!);
              }
              navigator.pop();
              _refreshWeeks();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Analysis'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createWeek,
        icon: const Icon(Icons.add),
        label: const Text('Create Week'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _weeks.isEmpty
              ? const Center(child: Text('No weeks created yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _weeks.length,
                  itemBuilder: (context, index) {
                    final week = _weeks[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_month, size: 40),
                        title: Text(
                          week.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Credit: ₹${week.totalCredit.toStringAsFixed(0)}',
                                      style: const TextStyle(color: Colors.green)),
                                  Text('Debit: ₹${week.totalDebit.toStringAsFixed(0)}',
                                      style: const TextStyle(color: Colors.red)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Net Profit: ₹${week.netProfit.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: week.netProfit >= 0
                                      ? Colors.blue
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(week),
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WeekLedgerScreen(week: week),
                            ),
                          );
                          _refreshWeeks();
                        },
                      ),
                    );
                  },
                ),
    );
  }
}