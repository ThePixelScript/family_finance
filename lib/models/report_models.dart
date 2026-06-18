class ReportsOverviewSummary {
  final double totalOutstanding;
  final double totalAdvance;
  final int customersWithDueBalance;
  final int totalWeeks;
  final double bestWeekProfit;

  ReportsOverviewSummary({
    required this.totalOutstanding,
    required this.totalAdvance,
    required this.customersWithDueBalance,
    required this.totalWeeks,
    required this.bestWeekProfit,
  });

  // Fixed: Named factory constructor matches immediately enclosing class name cleanly
  factory ReportsOverviewSummary.initial() {
    return ReportsOverviewSummary(
      totalOutstanding: 0.0,
      totalAdvance: 0.0,
      customersWithDueBalance: 0,
      totalWeeks: 0,
      bestWeekProfit: 0.0,
    );
  }
}

class WeeklyReportItem {
  final int? id;
  final String startDate;
  final String endDate;
  final int totalEntriesCount;
  final double totalCredit;
  final double totalDebit;
  final double netProfit;

  WeeklyReportItem({
    this.id,
    required this.startDate,
    required this.endDate,
    required this.totalEntriesCount,
    required this.totalCredit,
    required this.totalDebit,
    required this.netProfit,
  });
}

class MonthlyCustomerActivityItem {
  final String month;
  final double totalCredit;
  final double totalDebit;
  final double netChange;

  MonthlyCustomerActivityItem({
    required this.month,
    required this.totalCredit,
    required this.totalDebit,
    required this.netChange,
  });
}

class MonthlyBusinessActivityItem {
  final String month;
  final double totalCredit;
  final double totalDebit;
  final double netProfit;

  MonthlyBusinessActivityItem({
    required this.month,
    required this.totalCredit,
    required this.totalDebit,
    required this.netProfit,
  });
}

class CustomerReportItem {
  final int id;
  final String name;
  final String phone;
  final double totalCredit;
  final double totalDebit;
  final double netBalance;

  CustomerReportItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.totalCredit,
    required this.totalDebit,
    required this.netBalance,
  });
}