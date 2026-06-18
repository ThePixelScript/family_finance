class Week {
  final int? id;
  final String startDate;
  final String endDate;

  Week({
    this.id,
    required this.startDate,
    required this.endDate,
  });

  String get title {
    return '$startDate - $endDate';
  }
}