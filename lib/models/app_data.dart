import 'customer.dart';
import 'week.dart';

class AppData {
  static List<Customer> customers = [
    Customer(
      id: 1,
      name: 'Ramesh',
      phone: '9876543210',
    ),
    Customer(
      id: 2,
      name: 'Suresh',
      phone: '9876543211',
    ),
  ];

  static List<Week> weeks = [
    Week(
      id: 1,
      startDate: '01 Jun',
      endDate: '07 Jun',
    ),
    Week(
      id: 2,
      startDate: '08 Jun',
      endDate: '14 Jun',
    ),
  ];
}