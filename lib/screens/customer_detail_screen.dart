import 'package:flutter/material.dart';

import '../database/customer_transaction_repository.dart';
import '../widgets/customer_balance_card.dart';
import '../widgets/customer_action_buttons.dart';
import '../widgets/ledger_table_layout.dart';
import '../widgets/ledger_table_row.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int customerId;
  final String customerName;

  const CustomerDetailScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState
    extends State<CustomerDetailScreen> {

  final CustomerTransactionRepository repository =
      CustomerTransactionRepository();

  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {

    final data =
        await repository.getTransactions(
      widget.customerId,
    );

    setState(() {
      transactions = data;
    });
  }

  double get totalCredit {

    return transactions.fold(
      0,
      (sum, item) =>
          sum +
          ((item['credit'] ?? 0) as num)
              .toDouble(),
    );
  }

  double get totalDebit {

    return transactions.fold(
      0,
      (sum, item) =>
          sum +
          ((item['debit'] ?? 0) as num)
              .toDouble(),
    );
  }

  double get balance {
    return totalCredit - totalDebit;
  }

  Future<void> addTransaction(
    bool isCredit,
  ) async {

    final descriptionController =
        TextEditingController();

    final amountController =
        TextEditingController();

    String? amountError;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              isCredit
                  ? 'YOU GAVE'
                  : 'YOU GOT',
            ),
            content: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [

                TextField(
                  controller:
                      descriptionController,
                  decoration:
                      const InputDecoration(
                    labelText: 'Description',
                  ),
                ),

                TextField(
                  controller:
                      amountController,
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      InputDecoration(
                    labelText: 'Amount',
                    errorText: amountError,
                  ),
                  onChanged: (_) {
                    if (amountError != null) {
                      setDialogState(() {
                        amountError = null;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [

              ElevatedButton(
                onPressed: () async {

                  final amountText =
                      amountController.text
                          .trim();

                  if (amountText.isEmpty) {
                    setDialogState(() {
                      amountError =
                          'Amount is required';
                    });
                    return;
                  }

                  final amount =
                      double.tryParse(
                    amountText,
                  );

                  if (amount == null) {
                    setDialogState(() {
                      amountError =
                          'Enter a valid amount';
                    });
                    return;
                  }

                  await repository
                      .insertTransaction(
                    customerId:
                        widget.customerId,
                    date: DateTime.now()
                        .toString()
                        .substring(0, 10),
                    description:
                        descriptionController
                            .text,
                    credit:
                        isCredit ? amount : 0,
                    debit:
                        isCredit ? 0 : amount,
                  );

                  if (!context.mounted) return;

                  Navigator.pop(context);
                },
                child:
                    const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    await loadTransactions();
  }

  Future<void> deleteTransaction(
    int id,
  ) async {

    await repository.deleteTransaction(id);

    await loadTransactions();
  }

  Future<void> editTransaction(
    Map<String, dynamic> transaction,
  ) async {
    final descriptionController =
        TextEditingController(
      text: transaction['description']
          .toString(),
    );

    final creditController =
        TextEditingController(
      text: ((transaction['credit'] ?? 0) as num)
          .toDouble()
          .toStringAsFixed(0),
    );

    final debitController =
        TextEditingController(
      text: ((transaction['debit'] ?? 0) as num)
          .toDouble()
          .toStringAsFixed(0),
    );

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Transaction'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              TextField(
                controller: creditController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Credit',
                ),
              ),
              TextField(
                controller: debitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Debit',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await repository.updateTransaction(
                id: transaction['id'] as int,
                description:
                    descriptionController.text,
                credit: double.tryParse(
                      creditController.text,
                    ) ??
                    0,
                debit: double.tryParse(
                      debitController.text,
                    ) ??
                    0,
              );

              if (!mounted) return;

              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    await loadTransactions();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.customerName),
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            children: [

              CustomerBalanceCard(
                balance: balance,
              ),

              const SizedBox(height: 12),

              CustomerActionButtons(
                onYouGave: () =>
                    addTransaction(true),
                onYouGot: () =>
                    addTransaction(false),
              ),

              const SizedBox(height: 12),

              const LedgerTableHeader(
                showDate: true,
              ),

              const Divider(height: 1),

              Expanded(
                child: ListView.builder(
                  itemCount:
                      transactions.length,
                  itemBuilder:
                      (context, index) {

                    final t =
                        transactions[index];

                    return CustomerTransactionTableRow(
                      date: t['date']
                          .toString(),
                      description: t[
                              'description']
                          .toString(),
                      credit: ((t['credit'] ??
                                  0) as num)
                              .toDouble(),
                      debit: ((t['debit'] ??
                                  0) as num)
                              .toDouble(),
                      onEdit: () {
                        editTransaction(t);
                      },
                      onDelete: () {
                        deleteTransaction(
                          t['id'],
                        );
                      },
                    );
                  },
                ),
              ),

              const Divider(height: 1),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  const Text(
                    'Total Credit',
                  ),
                  Text(
                    '₹${totalCredit.toStringAsFixed(0)}',
                  ),
                ],
              ),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  const Text(
                    'Total Debit',
                  ),
                  Text(
                    '₹${totalDebit.toStringAsFixed(0)}',
                  ),
                ],
              ),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  const Text(
                    'Balance',
                  ),
                  Text(
                    '₹${balance.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}