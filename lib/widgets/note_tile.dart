import 'package:flutter/material.dart';

class NoteTile extends StatelessWidget {
  final String content;
  final DateTime date;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const NoteTile({
    super.key,
    required this.content,
    required this.date,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.deepPurple),
                    onPressed: onEdit,
                    tooltip: "Edit Note",
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: "Delete Note",
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
