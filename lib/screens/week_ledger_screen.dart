import 'package:flutter/material.dart';

import '../database/week_entry_repository.dart';
import '../models/week.dart';
import '../models/week_entry.dart';
import '../widgets/ledger_table_layout.dart';
import '../widgets/ledger_table_row.dart';

class WeekLedgerScreen extends StatefulWidget {
  final Week week;

  const WeekLedgerScreen({super.key, required this.week});

  @override
  State<WeekLedgerScreen> createState() =>
      _WeekLedgerScreenState();
}

class _WeekLedgerScreenState
    extends State<WeekLedgerScreen> {
  final WeekEntryRepository repository =
      WeekEntryRepository();

  List<WeekEntry> entries = [];
  double totalCredit = 0;
  double totalDebit = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLedger();
  }

  Future<void> loadLedger() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      repository.getEntries(weekId: widget.week.id),
      repository.getTotals(weekId: widget.week.id),
    ]);

    if (!mounted) return;

    final totals =
        results[1] as Map<String, double>;

    setState(() {
      entries = results[0] as List<WeekEntry>;
      totalCredit = totals['totalCredit'] ?? 0;
      totalDebit = totals['totalDebit'] ?? 0;
      _isLoading = false;
    });
  }

  double get netProfit {
    return totalCredit - totalDebit;
  }

  void addEntry() {
    final descriptionController =
        TextEditingController();

    final creditController =
        TextEditingController();

    final debitController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Entry'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller:
                    descriptionController,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Description',
                ),
              ),
              TextField(
                controller:
                    creditController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText: 'Credit',
                ),
              ),
              TextField(
                controller:
                    debitController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText: 'Debit',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text(
              'Cancel',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await repository.insertEntry(
                weekId: widget.week.id,
                description:
                    descriptionController
                        .text,
                credit: double.tryParse(
                        creditController
                            .text) ??
                    0,
                debit: double.tryParse(
                        debitController
                            .text) ??
                    0,
              );

              if (!mounted) return;

              Navigator.pop(context);

              await loadLedger();
            },
            child: const Text(
              'Save',
            ),
          ),
        ],
      ),
    );
  }

  void editEntry(WeekEntry entry) {
    final descriptionController =
        TextEditingController(
      text: entry.description,
    );

    final creditController =
        TextEditingController(
      text: entry.credit.toString(),
    );

    final debitController =
        TextEditingController(
      text: entry.debit.toString(),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Entry'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller:
                    descriptionController,
              ),
              TextField(
                controller:
                    creditController,
              ),
              TextField(
                controller:
                    debitController,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await repository.updateEntry(
                id: entry.id!,
                description:
                    descriptionController
                        .text,
                credit: double.tryParse(
                        creditController
                            .text) ??
                    0,
                debit: double.tryParse(
                        debitController
                            .text) ??
                    0,
              );

              if (!mounted) return;

              Navigator.pop(context);

              await loadLedger();
            },
            child: const Text(
              'Update',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteEntry(int id) async {
    await repository.deleteEntry(id);
    await loadLedger();
  }

  @override
  Widget build(
      BuildContext context) {
    const fabSize = 56.0;
    const fabMargin = 16.0;
    final bottomFabPadding =
        fabSize + fabMargin * 2;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Ledger: ${widget.week.title}'),
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: addEntry,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            12,
            12,
            12,
            12 + bottomFabPadding,
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Container(
                      color: Colors.grey[200],
                      child: const LedgerTableHeader(
                        showDate: false,
                      ),
                    ),
                    Expanded(
                      child: entries.isEmpty
                          ? const Center(child: Text('No entries for this week.'))
                          : ListView.builder(
                              itemCount:
                                  entries.length,
                              itemBuilder:
                                  (context, index) {
                                final entry =
                                    entries[index];

                                return WeekLedgerTableRow(
                                  description:
                                      entry.description,
                                  credit: entry.credit,
                                  debit: entry.debit,
                                  onEdit: () {
                                    editEntry(entry);
                                  },
                                  onDelete: () {
                                    deleteEntry(
                                      entry.id!,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                    const Divider(height: 1),
                    summaryRow(
                      'Total Credit',
                      totalCredit,
                    ),
                    summaryRow(
                      'Total Debit',
                      totalDebit,
                    ),
                    const Divider(height: 1),
                    summaryRow(
                      'Net Profit',
                      netProfit,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget summaryRow(
    String title,
    double value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
              vertical: 4),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Text(
            title,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          Text(
            '₹${value.toStringAsFixed(0)}',
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}