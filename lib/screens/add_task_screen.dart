import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../helpers/firebase_service.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? existingTask;

  const AddTaskScreen({super.key, this.existingTask});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebase = FirebaseService();

  late String _title;
  String _description = '';
  DateTime _selectedDate = DateTime.now();
  int _priority = 0;

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      final t = widget.existingTask!;
      _title = t.title;
      _description = t.description;
      _selectedDate = t.date;
      _priority = t.priority;
    } else {
      _title = '';
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _pickPriority() async {
    int selected = _priority;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Task Priority'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(3, (index) {
            final priorities = ['Low', 'Medium', 'High'];

            return ChoiceChip(
              label: Text(priorities[index]),
              selected: selected == index,
              onSelected: (_) {
                setState(() {
                  selected = index;
                  _priority = index;
                  Navigator.pop(context);

                 
                  if (index == 2) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("High Priority!"),
                          content: const Text(
                              "This task is marked as high priority.\nMake sure to complete it on time."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            )
                          ],
                        ),
                      );
                    });
                  }
                });
              },
              selectedColor: index == 0
                  ? Colors.green
                  : index == 1
                      ? Colors.orange
                      : Colors.red,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: selected == index ? Colors.white : Colors.black,
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final task = Task(
        id: widget.existingTask?.id,
        title: _title,
        description: _description,
        date: _selectedDate,
        priority: _priority,
        notes: widget.existingTask?.notes ?? '',
        isDone: widget.existingTask?.isDone ?? false,
      );

      if (widget.existingTask == null) {
        await _firebase.addTask(task);
      } else {
        await _firebase.updateTask(task);
      }

      if (context.mounted) Navigator.pop(context, task);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Row(
              children: [
                const SizedBox(width: 20),
                Text(
                  widget.existingTask == null ? 'New Task' : 'Edit Task',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _title,
                        decoration: InputDecoration(
                          labelText: 'Task Title',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a title'
                            : null,
                        onSaved: (value) => _title = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _description,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onSaved: (value) => _description = value ?? '',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickDateTime,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade100,
                              foregroundColor: Colors.deepPurple,
                            ),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(DateFormat('EEE, dd MMM yyyy • hh:mm a')
                                .format(_selectedDate)),
                          ),
                          ElevatedButton.icon(
                            onPressed: _pickPriority,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade100,
                              foregroundColor: Colors.deepPurple,
                            ),
                            icon: const Icon(Icons.flag),
                            label: Text(['Low', 'Medium', 'High'][_priority]),
                          ),
                          ElevatedButton.icon(
                            onPressed: _saveTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.check),
                            label: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
