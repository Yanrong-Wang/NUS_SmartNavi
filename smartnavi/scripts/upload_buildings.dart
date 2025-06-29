import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCdqXoewKhagUVs1XB4K5SWzOGGTnNuEak",
      authDomain: "smartnavi-d11ab.firebaseapp.com",
      projectId: "smartnavi-d11ab",
      storageBucket: "smartnavi-d11ab.firebasestorage.app",
      messagingSenderId: "1095431222019",
      appId: "1:1095431222019:web:a67eb76c31f9d4230aef36",
      measurementId: "G-VVRZNLMVT2"
    ),
  );
  final firestore = FirebaseFirestore.instance;
  final buildingsCollection = firestore.collection('buildings');

  // read buildings.json 
  final file = File('assets/buildings.json');
  final contents = await file.readAsString();
  
  // decode json to Map
  final Map<String, dynamic> buildingsMap = jsonDecode(contents);

  for (var entry in buildingsMap.entries) {
    
    String buildingCode = entry.key; // e.g., 'LT17', 'LT16'
    Map<String, dynamic> buildingData = entry.value;

    String buildingName = buildingData['roomName'];
    double latitude = buildingData['location']['y']; 
    double longitude = buildingData['location']['x']; 

    final firestoreDoc = {
      'buildingCode': buildingCode,
      'buildingName': buildingName,
      'latitude': latitude,
      'longitude': longitude,
    };
    
    // upload to Firestore
    await buildingsCollection.doc(buildingCode).set(firestoreDoc);
  }
}