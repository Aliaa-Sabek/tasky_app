import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasky_app/models/task.dart';
import 'update_screen.dart'; // <-- تأكدي أنكِ مستوردة ملف التعديل هنا

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _priorityFilter = 'All';
  bool _showTodayOnly = false;
  String _selectedMonth = DateFormat('MMMM').format(DateTime.now());

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _deleteTask(String id) async {
    await FirebaseFirestore.instance.collection('tasks').doc(id).delete();
  }

  void _showAddTaskSheet(BuildContext context, String userId) {
    final titleController = TextEditingController();
    DateTime selectedDateTime = DateTime.now();
    String priority = 'Low';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              const Text("New Task",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(labelText: "Priority"),
                items: ["Low", "Medium", "High"]
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    priority = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDateTime,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                    );

                    if (pickedTime != null) {
                      setState(() {
                        selectedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: const Text("Pick Date & Time"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  int priorityValue = _stringToPriority(priority);
                  await FirebaseFirestore.instance.collection('tasks').add({
                    'title': titleController.text.trim(),
                    'description': '',
                    'date': selectedDateTime.toIso8601String(),
                    'priority': priorityValue,
                    'userId': userId,
                    'isDone': false,
                    'notes': '',
                  });
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white),
                child: const Text("Add Task"),
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> _filteredTasks(String userId) {
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  int _stringToPriority(String val) {
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

  String _priorityToString(int val) {
    switch (val) {
      case 0:
        return 'Low';
      case 1:
        return 'Medium';
      case 2:
        return 'High';
      default:
        return 'Low';
    }
  }

  Color _priorityColor(int val) {
    switch (val) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final months = List.generate(12, (i) => DateFormat('MMMM').format(DateTime(0, i + 1)));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: [
              TextSpan(text: 'Task'),
              TextSpan(
                text: 'y',
                style: TextStyle(color: Colors.yellow),
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.deepPurple),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          _showAddTaskSheet(context, userId!);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _priorityFilter,
                    decoration: const InputDecoration(
                      labelText: "Priority Filter",
                      border: OutlineInputBorder(),
                    ),
                    items: ['All', 'Low', 'Medium', 'High']
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _priorityFilter = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedMonth,
                  items: months
                      .map((month) => DropdownMenuItem(
                            value: month,
                            child: Text(month),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedMonth = val!;
                    });
                  },
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    const Text("Today Only"),
                    Switch(
                      value: _showTodayOnly,
                      onChanged: (val) {
                        setState(() {
                          _showTodayOnly = val;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _filteredTasks(userId!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allTasks = snapshot.data!.docs.map((doc) {
                  final map = doc.data() as Map<String, dynamic>;
                  return Task.fromMap(map, doc.id);
                }).where((task) {
                  final now = DateTime.now();
                  final isToday = task.date.year == now.year &&
                      task.date.month == now.month &&
                      task.date.day == now.day;

                  final matchesPriority =
                      _priorityFilter == 'All' ||
                          _priorityToString(task.priority) == _priorityFilter;

                  final matchesMonth = DateFormat('MMMM').format(task.date) == _selectedMonth;

                  return (!_showTodayOnly || isToday) && matchesPriority && matchesMonth;
                }).toList();

                if (allTasks.isEmpty) {
                  return const Center(
                    child: Text("No tasks match the filter."),
                  );
                }

                return ListView.builder(
                  itemCount: allTasks.length,
                  itemBuilder: (context, index) {
                    final task = allTasks[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UpdateScreen(task: task),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: _priorityColor(task.priority), size: 14),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task.title,
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('EEEE, MMM d • hh:mm a').format(task.date),
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.purple),
                                ),
                                child: Text("${index + 1}"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
