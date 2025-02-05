class Exercise {
  final int id;
  final String name;
  final int reps;
  final DateTime date;
  final int userId;

  Exercise({
    required this.id,
    required this.name,
    required this.reps,
    required this.date,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'reps': reps,
      'date': date.toIso8601String(),
      'userId': userId,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      reps: map['reps'],
      date: DateTime.parse(map['date']),
      userId: map['userId'],
    );
  }
}
