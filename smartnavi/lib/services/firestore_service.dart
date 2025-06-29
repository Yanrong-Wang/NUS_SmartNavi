import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a stream of all schedules
  Stream<List<Schedule>> getSchedules() {
    return _db.collection('schedules').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Schedule.fromFirestore(doc)).toList());
  }

  // Add a new schedule
  Future<void> addSchedule(Schedule schedule) {
    return _db.collection('schedules').add(schedule.toFirestore());
  }
  // Update a schedule
  Future<void> updateSchedule(String id, Schedule schedule) {
    return _db.collection('schedules').doc(id).update(schedule.toFirestore());
  }
  // Delete a schedule
  Future<void> deleteSchedule(String id) {
    return _db.collection('schedules').doc(id).delete();
  }
}
