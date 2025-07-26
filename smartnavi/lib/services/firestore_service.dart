import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';

class FirestoreService {
  //final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _schedulesCollection = 
      FirebaseFirestore.instance.collection('schedules');

  // Get a stream of all schedules
  Stream<List<Schedule>> getSchedules() {
    return _schedulesCollection
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromFirestore(doc))
            .toList());
  }

  // Add a new schedule
  Future<void> addSchedule(Schedule schedule) async {
    try {
      await _schedulesCollection.add(schedule.toFirestore());
    } catch (e) {
      throw Exception('Failed to add schedule: $e');
    }
  }

  // Update a schedule 
  Future<void> updateSchedule(Schedule schedule) async {
    try {
      await _schedulesCollection.doc(schedule.id).update(schedule.toFirestore());
    } catch (e) {
      throw Exception('Failed to update schedule: $e');
    }
  }

  // Delete a schedule
  Future<void> deleteSchedule(String id) async {
    try {
      await _schedulesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }

  Future<Schedule?> getScheduleById(String scheduleId) async {
    try {
      DocumentSnapshot doc = await _schedulesCollection.doc(scheduleId).get();
      if (doc.exists) {
        return Schedule.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get schedule: $e');
    }
  }

  // Get upcoming schedules
  Stream<List<Schedule>> getUpcomingSchedules() {
    return _schedulesCollection
        .where('eventDate', isGreaterThan: Timestamp.now())
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromFirestore(doc))
            .toList());
  }

  // Get today's schedules
  Stream<List<Schedule>> getTodaySchedules() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return _schedulesCollection
        .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('eventDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromFirestore(doc))
            .toList());
  }
}


