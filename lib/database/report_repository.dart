import 'database_helper.dart';
import '../models/report_models.dart';

class ReportRepository {
  Future<ReportsOverviewSummary> getReportsOverview() async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        COALESCE(c_balances.totalDueAmount, 0) AS totalOutstanding,
        COALESCE(c_balances.totalAdvanceAmount, 0) AS totalAdvance,
        COALESCE(c_balances.customersOwingCount, 0) AS customersWithDueBalance,
        (SELECT COUNT(*) FROM weeks) AS totalWeeks,
        COALESCE((
          SELECT (COALESCE(SUM(e.credit), 0) - COALESCE(SUM(e.debit), 0)) AS wp
          FROM weeks w
          LEFT JOIN week_entries e ON w.id = e.weekId
          GROUP BY w.id
          ORDER BY wp DESC
          LIMIT 1
        ), 0) AS bestWeekProfit
      FROM (
        SELECT 
          SUM(CASE WHEN balance > 0 THEN balance ELSE 0 END) AS totalDueAmount,
          SUM(CASE WHEN balance < 0 THEN ABS(balance) ELSE 0 END) AS totalAdvanceAmount,
          COUNT(CASE WHEN balance > 0 THEN 1 END) AS customersOwingCount
        FROM (
          SELECT COALESCE(SUM(credit), 0) - COALESCE(SUM(debit), 0) AS balance
          FROM customer_transactions
          GROUP BY customerId
        )
      ) AS c_balances;
    ''');

    // Fixed: References corrected named factory constructor
    if (results.isEmpty) return ReportsOverviewSummary.initial();
    final row = results.first;

    return ReportsOverviewSummary(
      totalOutstanding: (row['totalOutstanding'] as num?)?.toDouble() ?? 0.0,
      totalAdvance: (row['totalAdvance'] as num?)?.toDouble() ?? 0.0,
      customersWithDueBalance: (row['customersWithDueBalance'] as num?)?.toInt() ?? 0,
      totalWeeks: (row['totalWeeks'] as num?)?.toInt() ?? 0,
      bestWeekProfit: (row['bestWeekProfit'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Future<List<WeeklyReportItem>> getWeeklyReport() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        w.id, w.startDate, w.endDate,
        COUNT(e.id) AS totalEntriesCount,
        COALESCE(SUM(e.credit), 0) AS totalCredit,
        COALESCE(SUM(e.debit), 0) AS totalDebit,
        (COALESCE(SUM(e.credit), 0) - COALESCE(SUM(e.debit), 0)) AS netProfit
      FROM weeks w
      LEFT JOIN week_entries e ON w.id = e.weekId
      GROUP BY w.id
      ORDER BY w.startDate DESC;
    ''');

    return results.map((row) => WeeklyReportItem(
      id: row['id'] as int?,
      startDate: row['startDate'] as String? ?? '',
      endDate: row['endDate'] as String? ?? '',
      totalEntriesCount: (row['totalEntriesCount'] as num?)?.toInt() ?? 0,
      totalCredit: (row['totalCredit'] as num?)?.toDouble() ?? 0.0,
      totalDebit: (row['totalDebit'] as num?)?.toDouble() ?? 0.0,
      netProfit: (row['netProfit'] as num?)?.toDouble() ?? 0.0,
    )).toList();
  }

  Future<List<MonthlyCustomerActivityItem>> getMonthlyCustomerActivity() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        SUBSTR(date, 1, 7) AS month,
        SUM(credit) AS totalCredit,
        SUM(debit) AS totalDebit,
        (SUM(credit) - SUM(debit)) AS netChange
      FROM customer_transactions
      GROUP BY month
      ORDER BY month DESC;
    ''');

    return results.map((row) => MonthlyCustomerActivityItem(
      month: row['month'] as String? ?? 'Unknown',
      totalCredit: (row['totalCredit'] as num?)?.toDouble() ?? 0.0,
      totalDebit: (row['totalDebit'] as num?)?.toDouble() ?? 0.0,
      netChange: (row['netChange'] as num?)?.toDouble() ?? 0.0,
    )).toList();
  }

  Future<List<MonthlyBusinessActivityItem>> getMonthlyBusinessActivity() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        SUBSTR(w.startDate, 1, 7) AS month,
        SUM(e.credit) AS totalCredit,
        SUM(e.debit) AS totalDebit,
        (SUM(e.credit) - SUM(e.debit)) AS netProfit
      FROM weeks w
      JOIN week_entries e ON w.id = e.weekId
      GROUP BY month
      ORDER BY month DESC;
    ''');

    return results.map((row) => MonthlyBusinessActivityItem(
      month: row['month'] as String? ?? 'Unknown',
      totalCredit: (row['totalCredit'] as num?)?.toDouble() ?? 0.0,
      totalDebit: (row['totalDebit'] as num?)?.toDouble() ?? 0.0,
      netProfit: (row['netProfit'] as num?)?.toDouble() ?? 0.0,
    )).toList();
  }

  Future<List<CustomerReportItem>> getOutstandingCustomers() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        c.id, c.name, COALESCE(c.phone, '') AS phone,
        COALESCE(SUM(t.credit), 0) AS totalCredit,
        COALESCE(SUM(t.debit), 0) AS totalDebit,
        (COALESCE(SUM(t.credit), 0) - COALESCE(SUM(t.debit), 0)) AS netBalance
      FROM customers c
      JOIN customer_transactions t ON c.id = t.customerId
      GROUP BY c.id
      HAVING netBalance > 0
      ORDER BY netBalance DESC;
    ''');

    return results.map((row) => CustomerReportItem(
      id: row['id'] as int,
      name: row['name'] as String? ?? '',
      phone: row['phone'] as String? ?? '',
      totalCredit: (row['totalCredit'] as num?)?.toDouble() ?? 0.0,
      totalDebit: (row['totalDebit'] as num?)?.toDouble() ?? 0.0,
      netBalance: (row['netBalance'] as num?)?.toDouble() ?? 0.0,
    )).toList();
  }

  Future<List<CustomerReportItem>> getTopCustomers() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        c.id, c.name, COALESCE(c.phone, '') AS phone,
        COALESCE(SUM(t.credit), 0) AS totalCredit,
        COALESCE(SUM(t.debit), 0) AS totalDebit,
        (COALESCE(SUM(t.credit), 0) - COALESCE(SUM(t.debit), 0)) AS netBalance
      FROM customers c
      LEFT JOIN customer_transactions t ON c.id = t.customerId
      GROUP BY c.id
      ORDER BY ABS(COALESCE(SUM(t.credit), 0) - COALESCE(SUM(t.debit), 0)) DESC
      LIMIT 15;
    ''');

    return results.map((row) => CustomerReportItem(
      id: row['id'] as int,
      name: row['name'] as String? ?? '',
      phone: row['phone'] as String? ?? '',
      totalCredit: (row['totalCredit'] as num?)?.toDouble() ?? 0.0,
      totalDebit: (row['totalDebit'] as num?)?.toDouble() ?? 0.0,
      netBalance: (row['netBalance'] as num?)?.toDouble() ?? 0.0,
    )).toList();
  }
}