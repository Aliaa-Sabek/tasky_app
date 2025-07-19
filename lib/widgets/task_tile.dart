import 'package:flutter/material.dart';
import '../models/task.dart';
import '../screens/task_details_screen.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleDone;

  const TaskTile({super.key, required this.task, required this.onToggleDone});

  @override
  Widget build(BuildContext context) {
    final isDone = task.isDone;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone ? Colors.grey[300] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isDone ? Colors.green : Colors.grey,
              ),
              onPressed: onToggleDone,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.grey : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "P${task.priority}",
              style: const TextStyle(color: Colors.purple),
            ),
          ],
        ),
      ),
    );
  }
}
