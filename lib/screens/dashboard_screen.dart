import 'package:flutter/material.dart';

import '../database/dashboard_repository.dart';
import '../models/dashboard_summary.dart';
import 'customer_ledger_screen.dart';
import 'weekly_analysis_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardRepository _repository = DashboardRepository();
  DashboardSummary _summary = DashboardSummary.initial();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final data = await _repository.getDashboardSummary();

    if (!mounted) return;
    setState(() {
      _summary = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Finance Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData, // Strictly enforced correct parameter
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildSectionHeader('Primary Workspaces'),
                  const SizedBox(height: 12),
                  
                  _buildNavigationCard(
                    title: 'Customer Ledger',
                    subtitle: 'Manage client entries, accounts, and communications',
                    icon: Icons.people,
                    color: Colors.indigo,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CustomerLedgerScreen()),
                      );
                      _loadDashboardData();
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildNavigationCard(
                    title: 'Weekly Analysis',
                    subtitle: 'Track statements and ledger entries scoped by dates',
                    icon: Icons.analytics,
                    color: Colors.teal,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WeeklyAnalysisScreen()),
                      );
                      _loadDashboardData();
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSectionHeader('Financial Overview'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Total Customers',
                          value: '${_summary.totalCustomers}',
                          icon: Icons.person_outline,
                          color: Colors.blue[700]!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Total Transactions',
                          value: '${_summary.totalCustomerTransactions}',
                          icon: Icons.receipt_long,
                          color: Colors.purple[700]!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildMetricCard(
                    title: 'Total Due Amount (Owed to You)',
                    value: '₹${_summary.totalDueAmount.toStringAsFixed(0)}',
                    icon: Icons.arrow_upward,
                    color: Colors.red[700]!,
                    isLarge: true,
                  ),
                  const SizedBox(height: 12),
                  _buildMetricCard(
                    title: 'Total Advance Amount (Prepaid)',
                    value: '₹${_summary.totalAdvanceAmount.toStringAsFixed(0)}',
                    icon: Icons.arrow_downward,
                    color: Colors.green[700]!,
                    isLarge: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Current Week Profit',
                          value: '₹${_summary.currentWeekProfit.toStringAsFixed(0)}',
                          icon: Icons.trending_up,
                          color: _summary.currentWeekProfit >= 0 ? Colors.green[800]! : Colors.orange[800]!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Last Week Profit',
                          value: '₹${_summary.lastWeekProfit.toStringAsFixed(0)}',
                          icon: Icons.history,
                          color: Colors.grey[700]!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildMetricCard(
                    title: 'Total Weekly Entries Listed',
                    value: '${_summary.totalWeekEntries}',
                    icon: Icons.view_week,
                    color: Colors.blueGrey[700]!,
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader('More Features (Coming Soon)'),
                  const SizedBox(height: 12),
                  
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildPlaceholderGridCard('Reports', Icons.assessment),
                      _buildPlaceholderGridCard('Export', Icons.ios_share),
                      _buildPlaceholderGridCard('Backup', Icons.cloud_upload),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                radius: 24,
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isLarge = false,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(isLarge ? 16.0 : 12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              radius: isLarge ? 24 : 18,
              child: Icon(icon, color: color, size: isLarge ? 24 : 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isLarge ? 20 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderGridCard(String label, IconData icon) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Opacity(
        opacity: 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.grey[700]),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}