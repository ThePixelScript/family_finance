import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {

    final credit =
        (transaction['credit'] ?? 0)
            .toDouble();

    final debit =
        (transaction['debit'] ?? 0)
            .toDouble();

    return Card(
      margin: const EdgeInsets.only(
        bottom: 8,
      ),
      child: ListTile(

        title: Text(
          transaction['description']
              .toString(),
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        subtitle: Text(
          transaction['date']
              .toString(),
        ),

        trailing: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [

            Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [

                if (credit > 0)
                  Text(
                    '+ ₹${credit.toStringAsFixed(0)}',
                    style:
                        const TextStyle(
                      color: Colors.green,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                if (debit > 0)
                  Text(
                    '- ₹${debit.toStringAsFixed(0)}',
                    style:
                        const TextStyle(
                      color: Colors.red,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
              ],
            ),

            PopupMenuButton(
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

              onSelected: (value) {

                if (value == 'edit') {
                  onEdit();
                }

                if (value == 'delete') {
                  onDelete();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}