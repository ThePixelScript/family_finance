class Customer {
  final int? id;
  final String name;
  final String phone;
  final String? address;
  final String? notes;

  Customer({
    this.id,
    required this.name,
    this.phone = '',
    this.address,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'notes': notes,
    };
  }

  factory Customer.fromMap(
    Map<String, dynamic> map,
  ) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString(),
      notes: map['notes']?.toString(),
    );
  }
}
