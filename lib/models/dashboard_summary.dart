class DashboardSummary {
  final int totalCustomers;
  final double totalDueAmount;
  final double totalAdvanceAmount;
  final double currentWeekProfit;
  final double lastWeekProfit;
  final int totalCustomerTransactions;
  final int totalWeekEntries;

  DashboardSummary({
    required this.totalCustomers,
    required this.totalDueAmount,
    required this.totalAdvanceAmount,
    required this.currentWeekProfit,
    required this.lastWeekProfit,
    required this.totalCustomerTransactions,
    required this.totalWeekEntries,
  });

  factory DashboardSummary.initial() {
    return DashboardSummary(
      totalCustomers: 0,
      totalDueAmount: 0.0,
      totalAdvanceAmount: 0.0,
      currentWeekProfit: 0.0,
      lastWeekProfit: 0.0,
      totalCustomerTransactions: 0,
      totalWeekEntries: 0,
    );
  }
}