import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;
  final String title;
  final DateTime eventDate;
  final String locationName;
  final String userId; // 添加用户ID字段

  Schedule({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.locationName,
    required this.userId, // 必需的用户ID
  });

  // From Firestore document to Schedule object
  factory Schedule.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Schedule(
      id: doc.id,
      title: data['title'] ?? '',
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      locationName: data['locationName'] ?? '',
      userId: data['userId'] ?? '', // 从Firestore读取userId
    );
  }

  // From Schedule object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'eventDate': Timestamp.fromDate(eventDate),
      'locationName': locationName,
      'userId': userId, // 保存userId到Firestore
    };
  }
}