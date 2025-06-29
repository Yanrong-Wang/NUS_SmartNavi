import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;
  final String title;
  final DateTime eventDate;
  final String locationName;

  Schedule({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.locationName,
  });

  // From Firestore document to Schedule object
  factory Schedule.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Schedule(
      id: doc.id,
      title: data['title'] ?? '',
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      locationName: data['locationName'] ?? '',
    );
  }

  // From Schedule object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'eventDate': Timestamp.fromDate(eventDate),
      'locationName': locationName,
    };
  }
}