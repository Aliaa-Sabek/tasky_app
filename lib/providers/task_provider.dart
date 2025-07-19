import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> fetchTasks() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();

    _tasks = snapshot.docs.map((doc) {
      final data = doc.data();
      return Task.fromMap(data, doc.id);
    }).toList();

    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final docRef = await FirebaseFirestore.instance.collection('tasks').add({
      'title': task.title,
      'description': task.description,
      'date': task.date.toIso8601String(),
      'priority': task.priority,
      'isDone': task.isDone,
      'notes': task.notes,
      'userId': userId,
    });

    _tasks.add(Task(
      id: docRef.id,
      title: task.title,
      description: task.description,
      date: task.date,
      priority: task.priority,
      isDone: task.isDone,
      notes: task.notes,
    ));
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await FirebaseFirestore.instance.collection('tasks').doc(task.id).update(task.toMap());
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    await FirebaseFirestore.instance.collection('tasks').doc(id).delete();
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  List<Task> filterByPriority(String priority) {
    if (priority == 'All') return _tasks;
    final priorityValue = _priorityToInt(priority);
    return _tasks.where((task) => task.priority == priorityValue).toList();
  }

  int _priorityToInt(String val) {
    switch (val) {
      case 'Low':
        return 0;
      case 'Medium':
        return 1;
      case 'High':
        return 2;
      default:
        return 0;
    }
  }
}
