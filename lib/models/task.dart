class Task {
  String? id; // ID بييجي من Firestore بعد إضافة الـ Task
  String title;
  String description;
  DateTime date;
  int priority; // 0 = Low, 1 = Medium, 2 = High
  bool isDone;
  String notes;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.priority,
    this.isDone = false,
    this.notes = '',
  });

  /// تحويل الكائن إلى Map لتخزينه في Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'priority': priority,
      'isDone': isDone,
      'notes': notes,
    };
  }

  /// تحويل بيانات Firestore إلى كائن Task
  factory Task.fromMap(Map<String, dynamic> map, String docId) {
    return Task(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      priority: map['priority'] ?? 0,
      isDone: map['isDone'] ?? false,
      notes: map['notes'] ?? '',
    );
  }
}
      