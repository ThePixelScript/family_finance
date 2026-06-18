import 'package:flutter/material.dart';

import '../database/customer_repository.dart';
import '../database/customer_transaction_repository.dart';
import '../models/customer.dart';
import '../utils/phone_utils.dart';
import 'customer_detail_screen.dart';
import 'customer_profile_screen.dart';

class CustomerLedgerScreen extends StatefulWidget {
  const CustomerLedgerScreen({super.key});

  @override
  State<CustomerLedgerScreen> createState() =>
      _CustomerLedgerScreenState();
}

class _CustomerLedgerScreenState
    extends State<CustomerLedgerScreen> {

  final CustomerRepository repository =
      CustomerRepository();

  final CustomerTransactionRepository
      transactionRepository =
      CustomerTransactionRepository();

  List<Map<String, dynamic>> customers = [];

  Map<int, double> customerBalances = {};

  String searchText = '';

  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    final results = await Future.wait([
      repository.getCustomers(),
      transactionRepository.getCustomerBalances(),
    ]);

    if (!mounted) return;

    setState(() {
      customers = results[0]
          as List<Map<String, dynamic>>;
      customerBalances = results[1]
          as Map<int, double>;
    });
  }

  String formatBalance(double balance) {
    if (balance > 0) {
      return 'Due ₹${balance.toStringAsFixed(0)}';
    }
    if (balance < 0) {
      return 'Advance ₹${balance.abs().toStringAsFixed(0)}';
    }
    return 'Clear';
  }

  Customer _customerFromMap(
    Map<String, dynamic> map,
  ) {
    return Customer.fromMap(map);
  }

  Future<void> openLedger(
    Map<String, dynamic> customer,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CustomerDetailScreen(
          customerId: customer['id'],
          customerName:
              customer['name'],
        ),
      ),
    );

    await loadCustomers();
  }

  Future<void> openProfile(
    Map<String, dynamic> customer,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerProfileScreen(
          customerId: customer['id'] as int,
        ),
      ),
    );

    await loadCustomers();
  }

  Future<void> showCustomerForm({
    Customer? customer,
    bool notesOnly = false,
  }) async {
    final isEditing = customer != null;

    final nameController =
        TextEditingController(
      text: customer?.name ?? '',
    );

    final phoneController =
        TextEditingController(
      text: customer?.phone ?? '',
    );

    final addressController =
        TextEditingController(
      text: customer?.address ?? '',
    );

    final notesController =
        TextEditingController(
      text: customer?.notes ?? '',
    );

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          notesOnly
              ? 'Add Note'
              : isEditing
                  ? 'Edit Customer'
                  : 'Add Customer',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              if (!notesOnly) ...[
                TextField(
                  controller:
                      nameController,
                  decoration:
                      const InputDecoration(
                    labelText: 'Name',
                  ),
                  textCapitalization:
                      TextCapitalization
                          .words,
                ),
                TextField(
                  controller:
                      phoneController,
                  keyboardType:
                      TextInputType.phone,
                  decoration:
                      const InputDecoration(
                    labelText: 'Phone',
                  ),
                ),
                TextField(
                  controller:
                      addressController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Address (optional)',
                  ),
                  textCapitalization:
                      TextCapitalization
                          .sentences,
                  maxLines: 2,
                ),
              ],
              TextField(
                controller:
                    notesController,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Notes (optional)',
                ),
                textCapitalization:
                    TextCapitalization
                        .sentences,
                maxLines: 3,
                autofocus: notesOnly,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!notesOnly &&
                  nameController.text
                      .trim()
                      .isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Name is required',
                    ),
                  ),
                );
                return;
              }

              if (isEditing) {
                await repository.updateCustomer(
                  Customer(
                    id: customer.id,
                    name: notesOnly
                        ? customer.name
                        : nameController
                            .text
                            .trim(),
                    phone: notesOnly
                        ? customer.phone
                        : phoneController
                            .text
                            .trim(),
                    address: notesOnly
                        ? customer.address
                        : _emptyToNull(
                            addressController
                                .text,
                          ),
                    notes: _emptyToNull(
                      notesController.text,
                    ),
                  ),
                );
              } else {
                await repository
                    .insertCustomerData(
                  name: nameController.text
                      .trim(),
                  phone: phoneController
                      .text
                      .trim(),
                  address: _emptyToNull(
                    addressController.text,
                  ),
                  notes: _emptyToNull(
                    notesController.text,
                  ),
                );
              }

              if (!mounted) return;

              Navigator.pop(context);
            },
            child: Text(
              isEditing ? 'Update' : 'Save',
            ),
          ),
        ],
      ),
    );

    await loadCustomers();
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> confirmDeleteCustomer(
    Customer customer,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Delete Customer',
        ),
        content: Text(
          'Delete ${customer.name}? '
          'All ledger transactions '
          'will also be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              context,
              false,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.red,
              foregroundColor:
                  Colors.white,
            ),
            onPressed: () =>
                Navigator.pop(
              context,
              true,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await repository.deleteCustomer(
      customer.id!,
    );

    await loadCustomers();
  }

  void showCustomerOptions(
    Map<String, dynamic> customerMap,
  ) {
    final customer =
        _customerFromMap(customerMap);

    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Text(
                  customer.name,
                  style:
                      Theme.of(context)
                          .textTheme
                          .titleMedium,
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.person,
                ),
                title: const Text(
                  'View Customer',
                ),
                onTap: () {
                  Navigator.pop(context);
                  openProfile(customerMap);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.book,
                ),
                title: const Text(
                  'View Ledger',
                ),
                onTap: () {
                  Navigator.pop(context);
                  openLedger(customerMap);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.edit,
                ),
                title: const Text(
                  'Edit Customer',
                ),
                onTap: () {
                  Navigator.pop(context);
                  showCustomerForm(
                    customer: customer,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: const Text(
                  'Delete Customer',
                ),
                onTap: () {
                  Navigator.pop(context);
                  confirmDeleteCustomer(
                    customer,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.note_add,
                ),
                title: const Text(
                  'Add Note',
                ),
                onTap: () {
                  Navigator.pop(context);
                  showCustomerForm(
                    customer: customer,
                    notesOnly: true,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> addCustomer() async {
    await showCustomerForm();
  }

  @override
  Widget build(BuildContext context) {

    final filteredCustomers =
        customers.where((customer) {

      return customer['name']
          .toString()
          .toLowerCase()
          .contains(
            searchText.toLowerCase(),
          );

    }).toList();

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Customer Ledger'),
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: addCustomer,
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [

          Padding(
            padding:
                const EdgeInsets.all(12),
            child: TextField(
              decoration:
                  const InputDecoration(
                hintText:
                    'Search Customer',
                prefixIcon:
                    Icon(Icons.search),
                border:
                    OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount:
                  filteredCustomers.length,

              itemBuilder:
                  (context, index) {

                final customer =
                    filteredCustomers[index];

                final balance =
                    customerBalances[
                            customer['id']
                                as int] ??
                        0;

                final phone =
                    customer['phone']
                            ?.toString() ??
                        '';

                return Card(
                  child: ListTile(
                    leading:
                        const CircleAvatar(
                      child: Icon(
                        Icons.person,
                      ),
                    ),

                    title: Text(
                      customer['name'],
                    ),

                    subtitle: phone.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              showPhoneActions(
                                context,
                                phone,
                              );
                            },
                            child: Text(
                              phone,
                              style:
                                  TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                decoration:
                                    TextDecoration
                                        .underline,
                              ),
                            ),
                          )
                        : null,

                    trailing: Text(
                      formatBalance(balance),
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                        color: balance > 0
                            ? Colors.red[700]
                            : balance < 0
                                ? Colors
                                    .green[700]
                                : Colors
                                    .grey[600],
                      ),
                    ),

                    onTap: () {
                      openLedger(customer);
                    },

                    onLongPress: () {
                      showCustomerOptions(
                        customer,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
