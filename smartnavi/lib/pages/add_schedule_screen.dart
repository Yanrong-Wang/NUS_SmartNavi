import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:search_page/search_page.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart';
import '../models/buildings_model.dart';
import '../models/schedule_model.dart';
import '../services/firestore_service.dart';

@RoutePage()
class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Building? _selectedBuilding;
  List<Building> _buildings = [];

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadBuildingData();
  }

  Future<void> _loadBuildingData() async {
    final String jsonString = await rootBundle.loadString('assets/buildings.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    setState(() {
      _buildings = jsonList.map((json) => Building.fromJson(json)).toList();
    });
  }

  Future<void> _pickDateTime() async {
    // Pick Date
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    // Pick Time
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (!mounted) return; 
    if (time == null) return;

    setState(() {
      _selectedDate = date;
      _selectedTime = time;
    });
  }

  void _showSearchPage() {
    showSearch(
      context: context,
      delegate: SearchPage<Building>(
        items: _buildings,
        searchLabel: 'Search building name or code...',
        suggestion: const Center(
          child: Text('Filter buildings by name or code'),
        ),
        failure: const Center(
          child: Text('No building found :('),
        ),
        filter: (building) => [
          building.buildingName,
          building.buildingCode,
        ],
        builder: (building) => ListTile(
          title: Text(building.buildingName),
          subtitle: Text(building.buildingCode),
          onTap: () {
            setState(() {
              _selectedBuilding = building;
              _locationController.text = building.buildingName;
            });
            context.router.pop();
          },
        ),
      ),
    );
  }

  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null || _selectedBuilding == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date, time, and location.')),
        );
        return;
      }
      
      final eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final newSchedule = Schedule(
        id: '', // Firestore will generate ID
        title: _titleController.text,
        eventDate: eventDateTime,
        locationName: _selectedBuilding!.buildingName,
      );

      await _firestoreService.addSchedule(newSchedule);
      
      if (mounted) {
        context.router.pop();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Schedule Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Location Search Field
              TextFormField(
                controller: _locationController,
                readOnly: true,
                onTap: _showSearchPage,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Tap to search for a location',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Date and Time Picker
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    _selectedDate == null || _selectedTime == null
                      ? 'Select Date & Time'
                      : '${DateFormat.yMMMd().format(_selectedDate!)} at ${DateFormat.jm().format(DateTime(2022, 1, 1, _selectedTime!.hour, _selectedTime!.minute))}',
                  ),
                  onTap: _pickDateTime,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveSchedule,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Schedule'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
