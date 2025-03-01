class Exercise {
  final int id;
  final String name;
  final int reps;
  final int userId;

  Exercise({
    required this.id,
    required this.name,
    required this.reps,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'reps': reps,
      'userId': userId,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      reps: map['reps'],
      userId: map['userId'],
    );
  }
}
