import 'package:flutter/material.dart';

abstract final class LedgerColumnWidths {
  static const double date = 76;
  static const double amount = 60;
  static const double action = 48;
}

class LedgerTableHeader extends StatelessWidget {
  final bool showDate;

  const LedgerTableHeader({
    super.key,
    this.showDate = false,
  });

  static const _headerStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 13,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      child: Row(
        children: [
          if (showDate)
            const SizedBox(
              width: LedgerColumnWidths.date,
              child: Text(
                'Date',
                style: _headerStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const Expanded(
            child: Text(
              'Description',
              style: _headerStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            width: LedgerColumnWidths.amount,
            child: Text(
              'Credit',
              style: _headerStyle,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            width: LedgerColumnWidths.amount,
            child: Text(
              'Debit',
              style: _headerStyle,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            width: LedgerColumnWidths.action,
          ),
        ],
      ),
    );
  }
}
