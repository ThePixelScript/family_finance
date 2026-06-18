import 'database_helper.dart';

class CustomerTransactionRepository {

  Future<int> insertTransaction({
    required int customerId,
    required String date,
    required String description,
    required double credit,
    required double debit,
  }) async {

    final db =
        await DatabaseHelper.instance.database;

    return await db.insert(
      'customer_transactions',
      {
        'customerId': customerId,
        'date': date,
        'description': description,
        'credit': credit,
        'debit': debit,
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

  Future<int> updateTransaction({
    required int id,
    required String description,
    required double credit,
    required double debit,
  }) async {
    final db =
        await DatabaseHelper.instance.database;

    return await db.update(
      'customer_transactions',
      {
        'description': description,
        'credit': credit,
        'debit': debit,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, double>> getCustomerBalanceSummary(
    int customerId,
  ) async {
    final db =
        await DatabaseHelper.instance.database;

    final results = await db.rawQuery('''
      SELECT COALESCE(SUM(credit), 0) AS totalCredit,
             COALESCE(SUM(debit), 0) AS totalDebit
      FROM customer_transactions
      WHERE customerId = ?
    ''', [customerId]);

    final row = results.first;
    final totalCredit =
        (row['totalCredit'] as num).toDouble();
    final totalDebit =
        (row['totalDebit'] as num).toDouble();

    return {
      'totalCredit': totalCredit,
      'totalDebit': totalDebit,
      'balance': totalCredit - totalDebit,
    };
  }

  Future<Map<int, double>> getCustomerBalances() async {
    final db =
        await DatabaseHelper.instance.database;

    final results = await db.rawQuery('''
      SELECT customerId,
             COALESCE(SUM(credit), 0) -
             COALESCE(SUM(debit), 0) AS balance
      FROM customer_transactions
      GROUP BY customerId
    ''');

    return {
      for (final row in results)
        row['customerId'] as int:
            (row['balance'] as num).toDouble(),
    };
  }
}