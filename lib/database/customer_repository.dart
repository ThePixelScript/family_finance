import '../models/customer.dart';
import 'database_helper.dart';

class CustomerRepository {
  Future<int> insertCustomer(
    Customer customer,
  ) async {
    final db =
        await DatabaseHelper.instance.database;

    return await db.insert(
      'customers',
      {
        'name': customer.name,
        'phone': customer.phone,
        'address': customer.address,
        'notes': customer.notes,
      },
    );
  }

  Future<int> insertCustomerData({
    required String name,
    String phone = '',
    String? address,
    String? notes,
  }) async {
    final db =
        await DatabaseHelper.instance.database;

    return await db.insert(
      'customers',
      {
        'name': name,
        'phone': phone,
        'address': address,
        'notes': notes,
      },
    );
  }

  Future<int> updateCustomer(
    Customer customer,
  ) async {
    final db =
        await DatabaseHelper.instance.database;

    return await db.update(
      'customers',
      {
        'name': customer.name,
        'phone': customer.phone,
        'address': customer.address,
        'notes': customer.notes,
      },
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<List<Map<String, dynamic>>>
      getCustomers() async {
    final db =
        await DatabaseHelper.instance.database;

    return await db.query(
      'customers',
      orderBy: 'name ASC',
    );
  }

  Future<Map<String, dynamic>?> getCustomerById(
    int id,
  ) async {
    final db =
        await DatabaseHelper.instance.database;

    final results = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  Future<int> deleteCustomer(
    int id,
  ) async {
    final db =
        await DatabaseHelper.instance.database;

    await db.delete(
      'customer_transactions',
      where: 'customerId = ?',
      whereArgs: [id],
    );

    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
