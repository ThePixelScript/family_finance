class Week {
  final int? id;
  final String startDate;
  final String endDate;
  
  // Aggregate data parameters filled via SQLite GROUP BY calculations
  final double totalCredit;
  final double totalDebit;
  final double netProfit;

  Week({
    this.id,
    required this.startDate,
    required this.endDate,
    this.totalCredit = 0.0,
    this.totalDebit = 0.0,
    this.netProfit = 0.0,
  });

  String get title {
    return '$startDate - $endDate';
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  factory Week.fromMap(Map<String, dynamic> map) {
    return Week(
      id: map['id'] as int?,
      startDate: map['startDate'] as String,
      endDate: map['endDate'] as String,
      totalCredit: (map['totalCredit'] as num?)?.toDouble() ?? 0.0,
      totalDebit: (map['totalDebit'] as num?)?.toDouble() ?? 0.0,
      netProfit: (map['netProfit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}