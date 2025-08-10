import 'package:flutter/material.dart';
import 'package:search_page/search_page.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/buildings.dart';
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
  final _titleInput = TextEditingController();
  final _locationInput = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  Building? _selectedBuilding;
  List<Building> _buildings = [];

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadBuildingData();
  }

  Future<void> _loadBuildingData() async {
    final buildingsMap = await Building.buildings;
    setState(() {
      _buildings = buildingsMap.values.toList();
      _buildings.sort((a, b) => a.roomName.compareTo(b.roomName));
    });
  }

  // Pick date 
  Future<void> _pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null && date != _selectedDate) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  // Pick start time
  Future<void> _pickStartTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
    );
    if (time != null && time != _selectedStartTime) {
      setState(() {
        _selectedStartTime = time;
        // If the end time is eearlier than the start time, set it as null
        if (_selectedEndTime != null) {
          final startMinutes = _selectedStartTime!.hour * 60 + _selectedStartTime!.minute;
          final endMinutes = _selectedEndTime!.hour * 60 + _selectedEndTime!.minute;
          if (endMinutes < startMinutes) {
            _selectedEndTime = null;
          }
        }
      });
    }
  }

  // Pick end time
  Future<void> _pickEndTime() async {
    // Ensure start time is selected before picking end time
    if (_selectedStartTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start time first.')),
      );
      return;
    }

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? _selectedStartTime!,
    );
    if (time != null) {
      // Check if end time is earlier than start time
      final startMinutes = _selectedStartTime!.hour * 60 + _selectedStartTime!.minute;
      final endMinutes = time.hour * 60 + time.minute;

      if (endMinutes < startMinutes) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('End time cannot be earlier than start time.')),
          );
        }
        return;
      }
      setState(() {
        _selectedEndTime = time;
      });
    }
  }

  void _showSearchPage() {
    showSearch(
      context: context,
      delegate: SearchPage<Building>(
        items: _buildings,
        searchLabel: 'Search building name ...',
        suggestion: const Center(
          child: Text('Filter buildings by name'),
        ),
        failure: const Center(
          child: Text('No building found :('),
        ),
        filter: (building) => [building.roomName],
        builder: (building) => ListTile(
          title: Text(building.roomName),
          onTap: () {
            setState(() {
              _selectedBuilding = building;
              _locationInput.text = building.roomName;
            });
            context.router.pop();
          },
        ),
      ),
    );
  }

  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedStartTime == null || _selectedBuilding == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date, start time, and location.')),
        );
        return;
      }

      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedStartTime!.hour,
        _selectedStartTime!.minute,
      );

      DateTime? endDateTime;
      if (_selectedEndTime != null) {
        endDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedEndTime!.hour,
          _selectedEndTime!.minute,
        );
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to create schedule')),
        );
        return;
      }

      final newSchedule = Schedule(
        id: '', // Firestore will generate ID
        title: _titleInput.text,
        eventDate: startDateTime,
        endDate: endDateTime, 
        locationName: _selectedBuilding?.roomName ?? '', 
        userId: currentUser.uid, 
      );
      try{
        await _firestoreService.addSchedule(newSchedule);
      } catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding schedule: $e')),
          );
        }
        return;
      }
      
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
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children:[
                    TextFormField(
                      controller: _titleInput,
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
                controller: _locationInput,
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
              
              // Seperate pickers for date, start time and end time
              // Date Picker
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Date'),
                subtitle: Text(
                  _selectedDate == null ? 'Select Date' : DateFormat.yMMMd().format(_selectedDate!),
                ),
                onTap: _pickDate,
                contentPadding: EdgeInsets.zero,
              ),
              // Start Time Picker
              ListTile(
                leading: const Icon(Icons.access_time_outlined),
                title: const Text('Start Time'),
                subtitle: Text(
                  _selectedStartTime == null ? 'Select Start Time' : _selectedStartTime!.format(context),
                ),
                onTap: _pickStartTime,
                contentPadding: EdgeInsets.zero,
              ),
              // End Time Picker
              ListTile(
                leading: const Icon(Icons.timelapse_outlined),
                title: const Text('End Time (Optional)'),
                subtitle: Text(
                  _selectedEndTime == null ? 'Select End Time' : _selectedEndTime!.format(context),
                ),
                onTap: _pickEndTime,
                enabled: _selectedStartTime != null, // only enable if start time is selected
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32), 
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSchedule,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.router.pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}