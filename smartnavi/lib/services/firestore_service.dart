import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a stream of all schedules
  Stream<List<Schedule>> getSchedules() {
    return _db
        .collection('schedules')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Schedule.fromFirestore(doc)).toList(),
        );
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

  // Fetch all station names from Firestore
  Future<List<String>> getStationNames() async {
    try {
      final snapshot = await _db.collection('Venues').get();
      // Map the documents to a list of names
      final stationNames = snapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();
      return stationNames;
    } catch (e) {
      print("Error fetching station names: $e");
      // Return an empty list in case of an error
      return [];
    }
  }

  // Search for a route between two stations
  Future<String?> searchRoute(String startStation, String endStation) async {
    if (startStation.trim().isEmpty || endStation.trim().isEmpty) {
      return "Please select a valid start and end station.";
    }
    final String docId = '${startStation.trim()}_${endStation.trim()}';
    try {
      final DocumentSnapshot routeDoc = await _db
          .collection('Routes')
          .doc(docId)
          .get();
      if (routeDoc.exists) {
        final data = routeDoc.data() as Map<String, dynamic>?;
        return data?['Bus_name'] as String? ?? "Data format error";
      } else {
        return "No direct route found from $startStation to $endStation.";
      }
    } catch (e) {
      print("Error searching route: $e");
      return "Query failed. Please check your network connection and try again.";
    }
  }
}
