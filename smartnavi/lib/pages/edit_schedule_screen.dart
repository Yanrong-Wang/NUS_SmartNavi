import 'package:flutter/material.dart';
import 'package:search_page/search_page.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart';
import '../models/buildings.dart';
import '../models/schedule_model.dart';
import '../services/firestore_service.dart';

@RoutePage()
class EditScheduleScreen extends StatefulWidget {
  final String scheduleId;
  
  const EditScheduleScreen({
    super.key, 
    required this.scheduleId,
  });

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleInput = TextEditingController();
  final _locationInput = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Building? _selectedBuilding;
  List<Building> _buildings = [];
  Schedule? _currentSchedule;
  bool _isLoading = true;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadBuildingData(),
      _loadScheduleData(),
    ]);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadBuildingData() async {
    final buildingsMap = await Building.buildings;
    _buildings = buildingsMap.values.toList();
    _buildings.sort((a, b) => a.roomName.compareTo(b.roomName));
  }

  Future<void> _loadScheduleData() async {
    try {
      final schedule = await _firestoreService.getScheduleById(widget.scheduleId);
      if (schedule != null) {
        _currentSchedule = schedule;
        _titleInput.text = schedule.title;
        _locationInput.text = schedule.locationName;
        _selectedDate = schedule.eventDate;
        _selectedTime = TimeOfDay.fromDateTime(schedule.eventDate);
        
        // Find the building based on the location name
        _selectedBuilding = _buildings.firstWhere(
          (building) => building.roomName == schedule.locationName,
          orElse: () => _buildings.first,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading schedule: $e')),
        );
      }
    }
  }

  Future<void> _pickDateTime() async {
    // Pick Date
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

  // Pick Time
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
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

  Future<void> _updateSchedule() async {
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

      final updatedSchedule = Schedule(
        id: widget.scheduleId,
        title: _titleInput.text,
        eventDate: eventDateTime,
        locationName: _selectedBuilding!.roomName,
      );

      try {
        await _firestoreService.updateSchedule(updatedSchedule);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule updated successfully!')),
          );
          context.router.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating schedule: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteSchedule() async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Schedule'),
          content: const Text('Are you sure you want to delete this schedule?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await _firestoreService.deleteSchedule(widget.scheduleId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule deleted successfully!')),
          );
          context.router.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting schedule: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Schedule'),
        actions: [
          IconButton(
            onPressed: _deleteSchedule,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateSchedule,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Update Schedule'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _deleteSchedule,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Delete'),
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

  @override
  void dispose() {
    _titleInput.dispose();
    _locationInput.dispose();
    super.dispose();
  }
}