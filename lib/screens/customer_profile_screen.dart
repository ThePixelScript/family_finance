import 'package:flutter/material.dart';

import '../database/customer_repository.dart';
import '../database/customer_transaction_repository.dart';
import '../models/customer.dart';
import '../utils/phone_utils.dart';

class CustomerProfileScreen extends StatefulWidget {
  final int customerId;

  const CustomerProfileScreen({
    super.key,
    required this.customerId,
  });

  @override
  State<CustomerProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState
    extends State<CustomerProfileScreen> {
  final CustomerRepository _customerRepository =
      CustomerRepository();

  final CustomerTransactionRepository
      _transactionRepository =
      CustomerTransactionRepository();

  Customer? _customer;
  double _totalCredit = 0;
  double _totalDebit = 0;
  double _balance = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final results = await Future.wait([
      _customerRepository.getCustomerById(
        widget.customerId,
      ),
      _transactionRepository.getCustomerBalanceSummary(
        widget.customerId,
      ),
    ]);

    if (!mounted) return;

    final customerMap = results[0];
    final summary =
        results[1] as Map<String, double>;

    setState(() {
      _customer = customerMap != null
          ? Customer.fromMap(customerMap)
          : null;
      _totalCredit = summary['totalCredit'] ?? 0;
      _totalDebit = summary['totalDebit'] ?? 0;
      _balance = summary['balance'] ?? 0;
      _loading = false;
    });
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> editCustomer() async {
    final customer = _customer;
    if (customer == null) return;

    final nameController = TextEditingController(
      text: customer.name,
    );
    final phoneController = TextEditingController(
      text: customer.phone,
    );
    final addressController = TextEditingController(
      text: customer.address ?? '',
    );
    final notesController = TextEditingController(
      text: customer.notes ?? '',
    );

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                textCapitalization:
                    TextCapitalization.words,
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                ),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address (optional)',
                ),
                textCapitalization:
                    TextCapitalization.sentences,
                maxLines: 2,
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                textCapitalization:
                    TextCapitalization.sentences,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Name is required'),
                  ),
                );
                return;
              }

              await _customerRepository.updateCustomer(
                Customer(
                  id: customer.id,
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  address: _emptyToNull(
                    addressController.text,
                  ),
                  notes: _emptyToNull(
                    notesController.text,
                  ),
                ),
              );

              if (!mounted) return;

              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    await loadProfile();
  }

  Future<void> _launchCall() async {
    final phone = _customer?.phone ?? '';
    if (!isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid phone number available'),
        ),
      );
      return;
    }

    try {
      await launchPhoneCall(phone);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open dialer'),
        ),
      );
    }
  }

  Future<void> _launchWhatsApp() async {
    final phone = _customer?.phone ?? '';
    if (!isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid phone number available'),
        ),
      );
      return;
    }

    try {
      await launchWhatsAppChat(phone);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open WhatsApp'),
        ),
      );
    }
  }

  Widget _infoRow(
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                value.isEmpty ? '—' : value,
                style: TextStyle(
                  fontSize: 15,
                  color: onTap != null && value.isNotEmpty
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  decoration: onTap != null && value.isNotEmpty
                      ? TextDecoration.underline
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = _customer;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          customer?.name ?? 'Customer Profile',
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : customer == null
              ? const Center(
                  child: Text('Customer not found'),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge,
                                ),
                                const SizedBox(height: 12),
                                _infoRow(
                                  'Phone',
                                  customer.phone,
                                  onTap: customer.phone.isNotEmpty
                                      ? () => showPhoneActions(
                                            context,
                                            customer.phone,
                                          )
                                      : null,
                                ),
                                _infoRow(
                                  'Address',
                                  customer.address ?? '',
                                ),
                                _infoRow(
                                  'Notes',
                                  customer.notes ?? '',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _statRow(
                                  'Total Credit',
                                  '₹${_totalCredit.toStringAsFixed(0)}',
                                ),
                                _statRow(
                                  'Total Debit',
                                  '₹${_totalDebit.toStringAsFixed(0)}',
                                ),
                                const Divider(),
                                _statRow(
                                  'Current Balance',
                                  '₹${_balance.toStringAsFixed(0)}',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _launchCall,
                                icon: const Icon(Icons.phone),
                                label: const Text('Call'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _launchWhatsApp,
                                icon: const Icon(Icons.chat),
                                label: const Text('WhatsApp'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: editCustomer,
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Customer'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
