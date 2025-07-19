import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasky_app/helpers/firebase_service.dart';
import '../models/task.dart';

class UpdateScreen extends StatefulWidget {
  final Task task;

  const UpdateScreen({super.key, required this.task});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _date;
  late int _priority;
  late String _notes;

  @override
  void initState() {
    super.initState();
    _title = widget.task.title;
    _description = widget.task.description;
    _date = widget.task.date;
    _priority = widget.task.priority;
    _notes = widget.task.notes;
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedTask = Task(
        id: widget.task.id,
        title: _title,
        description: _description,
        date: _date,
        priority: _priority,
        notes: _notes,
        isDone: widget.task.isDone,
      );

      try {
        await FirebaseService().updateTask(updatedTask);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task: $e')),
        );
      }
    }
  }

  Future<void> _deleteTask() async {
    try {
      await FirebaseService().deleteTask(widget.task.id!);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: $e')),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTask,
            tooltip: 'Delete Task',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (value) => _title = value?.trim() ?? '',
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Title cannot be empty' : null,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value?.trim() ?? '',
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Select Date'),
                subtitle: Text(DateFormat.yMMMd().format(_date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Low')),
                  DropdownMenuItem(value: 1, child: Text('Medium')),
                  DropdownMenuItem(value: 2, child: Text('High')),
                ],
                onChanged: (value) {
                  setState(() {
                    _priority = value ?? 0;
                  });
                },
              ),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(labelText: 'Notes'),
                onSaved: (value) => _notes = value?.trim() ?? '',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateTask,
                child: const Text('Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
