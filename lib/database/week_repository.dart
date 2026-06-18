import 'database_helper.dart';
import '../models/week.dart';

class WeekRepository {
  Future<List<Week>> getWeeksWithSummaries() async {
    final db = await DatabaseHelper.instance.database;
    
    // Uses structural GROUP BY grouping to minimize storage passes
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        w.id,
        w.startDate,
        w.endDate,
        COALESCE(SUM(e.credit), 0) AS totalCredit,
        COALESCE(SUM(e.debit), 0) AS totalDebit,
        (COALESCE(SUM(e.credit), 0) - COALESCE(SUM(e.debit), 0)) AS netProfit
      FROM weeks w
      LEFT JOIN week_entries e ON w.id = e.weekId
      GROUP BY w.id
      ORDER BY w.startDate DESC
    ''');

    return results.map(Week.fromMap).toList();
  }

  Future<int> insertWeek(Week week) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('weeks', week.toMap());
  }

  Future<int> deleteWeek(int id) async {
    final db = await DatabaseHelper.instance.database;
    // Database configuration configuration cascading handles removing associated week_entries rows
    return await db.delete(
      'weeks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}