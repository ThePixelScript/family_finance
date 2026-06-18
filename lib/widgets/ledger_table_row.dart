import 'package:flutter/material.dart';

import 'ledger_table_layout.dart';

class CustomerTransactionTableRow extends StatelessWidget {
  final String date;
  final String description;
  final double credit;
  final double debit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomerTransactionTableRow({
    super.key,
    required this.date,
    required this.description,
    required this.credit,
    required this.debit,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 8,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black12,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: LedgerColumnWidths.date,
            child: Text(
              date,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(
            width: LedgerColumnWidths.amount,
            child: Text(
              credit == 0 ? '' : credit.toStringAsFixed(0),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(
            width: LedgerColumnWidths.amount,
            child: Text(
              debit == 0 ? '' : debit.toStringAsFixed(0),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(
            width: LedgerColumnWidths.action,
            height: LedgerColumnWidths.action,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              iconSize: 22,
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                }
                if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit Transaction'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Transaction'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WeekLedgerTableRow extends StatelessWidget {
  final String description;
  final double credit;
  final double debit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WeekLedgerTableRow({
    super.key,
    required this.description,
    required this.credit,
    required this.debit,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 8,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black12,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(
            width: LedgerColumnWidths.amount,
            child: Text(
              credit == 0 ? '' : credit.toStringAsFixed(0),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(
            width: LedgerColumnWidths.amount,
            child: Text(
              debit == 0 ? '' : debit.toStringAsFixed(0),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(
            width: LedgerColumnWidths.action,
            height: LedgerColumnWidths.action,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              iconSize: 22,
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                }
                if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
