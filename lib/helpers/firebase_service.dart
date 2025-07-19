import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirebaseService {
  final CollectionReference _taskCollection =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(Task task) async {
    final docRef = await _taskCollection.add(task.toMap());

   
    await _taskCollection.doc(docRef.id).update({'id': docRef.id});
  }

  Future<void> updateTask(Task task) async {
    await _taskCollection.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await _taskCollection.doc(id).delete();
  }

  Stream<List<Task>> getTasks() {
    return _taskCollection.orderBy('date', descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      },
    );
  }
}
