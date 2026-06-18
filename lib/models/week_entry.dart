class WeekEntry {
  final int? id;
  final int? weekId;
  final String description;
  final double credit;
  final double debit;

  WeekEntry({
    this.id,
    this.weekId,
    required this.description,
    required this.credit,
    required this.debit,
  });

  factory WeekEntry.fromMap(
    Map<String, dynamic> map,
  ) {
    return WeekEntry(
      id: map['id'] as int?,
      weekId: map['weekId'] as int?,
      description: map['description'] as String,
      credit: (map['credit'] as num).toDouble(),
      debit: (map['debit'] as num).toDouble(),
    );
  }
}
