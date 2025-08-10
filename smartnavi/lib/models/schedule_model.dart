import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;
  final String title;
  final DateTime eventDate;
  final DateTime? endDate;
  final String locationName;
  final String userId; 

  Schedule({
    required this.id,
    required this.title,
    required this.eventDate,
    this.endDate,
    required this.locationName,
    required this.userId, 
  });

  // From Firestore document to Schedule object
  factory Schedule.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Schedule(
      id: doc.id,
      title: data['title'] ?? '',
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      locationName: data['locationName'] ?? '',
      userId: data['userId'] ?? '', // Read userId from Firestore
    );
  }

  // From Schedule object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'eventDate': Timestamp.fromDate(eventDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'locationName': locationName,
      'userId': userId, // save userId to Firestore
    };
  }
}