import 'database_helper.dart';
import '../models/dashboard_summary.dart';

class DashboardRepository {
  Future<DashboardSummary> getDashboardSummary() async {
    final db = await DatabaseHelper.instance.database;

    // Cross-joined single atomic database query for low battery/wake-lock footprint
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        (SELECT COUNT(*) FROM customers) AS totalCustomers,
        (SELECT COUNT(*) FROM customer_transactions) AS totalCustomerTransactions,
        COALESCE(c_balances.totalDueAmount, 0) AS totalDueAmount,
        COALESCE(c_balances.totalAdvanceAmount, 0) AS totalAdvanceAmount,
        (SELECT COUNT(*) FROM week_entries) AS totalWeekEntries,
        COALESCE((
          SELECT (COALESCE(SUM(e.credit), 0) - COALESCE(SUM(e.debit), 0))
          FROM weeks w
          LEFT JOIN week_entries e ON w.id = e.weekId
          GROUP BY w.id
          ORDER BY w.startDate DESC
          LIMIT 1
        ), 0) AS currentWeekProfit,
        COALESCE((
          SELECT (COALESCE(SUM(e.credit), 0) - COALESCE(SUM(e.debit), 0))
          FROM weeks w
          LEFT JOIN week_entries e ON w.id = e.weekId
          GROUP BY w.id
          ORDER BY w.startDate DESC
          LIMIT 1 OFFSET 1
        ), 0) AS lastWeekProfit
      FROM (
        SELECT 
          SUM(CASE WHEN balance > 0 THEN balance ELSE 0 END) AS totalDueAmount,
          SUM(CASE WHEN balance < 0 THEN ABS(balance) ELSE 0 END) AS totalAdvanceAmount
        FROM (
          SELECT COALESCE(SUM(credit), 0) - COALESCE(SUM(debit), 0) AS balance
          FROM customer_transactions
          GROUP BY customerId
        )
      ) AS c_balances;
    ''');

    if (results.isEmpty) {
      return DashboardSummary.initial();
    }

    final row = results.first;

    return DashboardSummary(
      totalCustomers: (row['totalCustomers'] as num?)?.toInt() ?? 0,
      totalCustomerTransactions: (row['totalCustomerTransactions'] as num?)?.toInt() ?? 0,
      totalDueAmount: (row['totalDueAmount'] as num?)?.toDouble() ?? 0.0,
      totalAdvanceAmount: (row['totalAdvanceAmount'] as num?)?.toDouble() ?? 0.0,
      totalWeekEntries: (row['totalWeekEntries'] as num?)?.toInt() ?? 0,
      currentWeekProfit: (row['currentWeekProfit'] as num?)?.toDouble() ?? 0.0,
      lastWeekProfit: (row['lastWeekProfit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}