import '../models/customer_transaction.dart';
import 'database_helper.dart';

class TransactionRepository {
  Future<int> insertTransaction(
    CustomerTransaction transaction,
  ) async {
    final db =
        await DatabaseHelper.instance.database;

    return await db.insert(
      'customer_transactions',
      {
        'customerId':
            transaction.customerId,
        'date': transaction.date,
        'description':
            transaction.description,
        'credit':
            transaction.credit,
        'debit':
            transaction.debit,
      },
    );
  }

  Future<List<Map<String, dynamic>>>
      getTransactions(
    int customerId,
  ) async {
    final db =
        await DatabaseHelper.instance.database;

    return await db.query(
      'customer_transactions',
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'id DESC',
    );
  }

  Future<int> deleteTransaction(
    int id,
  ) async {
    final db =
        await DatabaseHelper.instance.database;

    return await db.delete(
      'customer_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}