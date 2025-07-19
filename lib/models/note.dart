class Note {
  final int? id;
  final String content;
  final DateTime createdAt;

  Note({this.id, required this.content, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
