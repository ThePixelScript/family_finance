import 'package:flutter/material.dart';

import '../database/report_repository.dart';
import '../models/report_models.dart';

// Fixed: Changed from StatefulWidget to StatelessWidget since it immediately routes to the stateful content pane
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ReportsScreenContent();
  }
}

class _ReportsScreenContent extends StatefulWidget {
  const _ReportsScreenContent();

  @override
  State<_ReportsScreenContent> createState() => _ReportsScreenContentState();
}

class _ReportsScreenContentState extends State<_ReportsScreenContent> {
  final ReportRepository _repository = ReportRepository();
  ReportsOverviewSummary _overview = ReportsOverviewSummary.initial();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllReportData();
  }

  Future<void> _loadAllReportData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final summaryData = await _repository.getReportsOverview();

    if (!mounted) return;
    setState(() {
      _overview = summaryData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Financial Reports'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Weekly Analytics'),
              Tab(text: 'Customer Monthly'),
              Tab(text: 'Business Monthly'),
              Tab(text: 'Outstanding Balances'),
              Tab(text: 'Top Stakeholders'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadAllReportData,
                child: Column(
                  children: [
                    _buildOverviewScrollHeader(),
                    const Divider(height: 1),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildWeeklyTabPane(),
                          _buildMonthlyCustomerTabPane(),
                          _buildMonthlyBusinessTabPane(),
                          _buildOutstandingTabPane(),
                          _buildTopCustomersTabPane(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOverviewScrollHeader() {
    return Container(
      height: 96,
      color: Colors.grey[50],
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        children: [
          _buildSummaryChip('Outstanding Due', '₹${_overview.totalOutstanding.toStringAsFixed(0)}', Colors.red[700]!),
          _buildSummaryChip('Total Advance', '₹${_overview.totalAdvance.toStringAsFixed(0)}', Colors.green[700]!),
          _buildSummaryChip('Owing Customers', '${_overview.customersWithDueBalance}', Colors.orange[800]!),
          _buildSummaryChip('Best Week Run', '₹${_overview.bestWeekProfit.toStringAsFixed(0)}', Colors.blue[700]!),
          _buildSummaryChip('Tracked Weeks', '${_overview.totalWeeks}', Colors.purple[700]!),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String title, String value, Color color) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withValues(alpha: 0.2), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidget(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyTabPane() {
    return FutureBuilder<List<WeeklyReportItem>>(
      future: _repository.getWeeklyReport(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        if (data.isEmpty) return _buildEmptyStateWidget('No historical weekly ranges constructed.');

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return Card(
              child: ListTile(
                title: Text('${item.startDate} to ${item.endDate}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('Entries count: ${item.totalEntriesCount}', style: const TextStyle(fontSize: 12)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${item.netProfit.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: item.netProfit >= 0 ? Colors.green[700] : Colors.red[700])),
                    Text('C: ${item.totalCredit.toStringAsFixed(0)} | D: ${item.totalDebit.toStringAsFixed(0)}', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMonthlyCustomerTabPane() {
    return FutureBuilder<List<MonthlyCustomerActivityItem>>(
      future: _repository.getMonthlyCustomerActivity(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        if (data.isEmpty) return _buildEmptyStateWidget('No customer transaction histories compiled.');

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_view_month),
                title: Text(item.month, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Net Change: ₹${item.netChange.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Credit: ${item.totalCredit.toStringAsFixed(0)} | Debit: ${item.totalDebit.toStringAsFixed(0)}', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMonthlyBusinessTabPane() {
    return FutureBuilder<List<MonthlyBusinessActivityItem>>(
      future: _repository.getMonthlyBusinessActivity(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        if (data.isEmpty) return _buildEmptyStateWidget('No core ledger business activity found.');

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.business_center_outlined),
                title: Text(item.month, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Profit: ₹${item.netProfit.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: item.netProfit >= 0 ? Colors.green[700] : Colors.red[700])),
                    Text('C: ${item.totalCredit.toStringAsFixed(0)} | D: ${item.totalDebit.toStringAsFixed(0)}', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOutstandingTabPane() {
    return FutureBuilder<List<CustomerReportItem>>(
      future: _repository.getOutstandingCustomers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        if (data.isEmpty) return _buildEmptyStateWidget('No outstanding account balances active.');

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return Card(
              child: ListTile(
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(item.phone.isEmpty ? 'No Phone' : item.phone, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                trailing: Text(
                  '₹${item.netBalance.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopCustomersTabPane() {
    return FutureBuilder<List<CustomerReportItem>>(
      future: _repository.getTopCustomers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        if (data.isEmpty) return _buildEmptyStateWidget('No ledger accounts registered.');

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('C: ${item.totalCredit.toStringAsFixed(0)} | D: ${item.totalDebit.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                trailing: Text(
                  '₹${item.netBalance.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: item.netBalance >= 0 ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}