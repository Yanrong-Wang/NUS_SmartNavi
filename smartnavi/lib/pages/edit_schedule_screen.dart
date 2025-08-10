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
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  Building? _selectedBuilding;
  List<Building> _buildings = [];
  bool _isLoading = true;
  Schedule? _currentSchedule;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadBuildingData();
    await _loadScheduleData(); // Now _buildings is guaranteed to be ready.
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
        _currentSchedule = schedule; // Store the current schedule
        _titleInput.text = schedule.title;
        _locationInput.text = schedule.locationName;
        _selectedDate = schedule.eventDate;
        _selectedStartTime = TimeOfDay.fromDateTime(schedule.eventDate);
        if (schedule.endDate != null) {
          _selectedEndTime = TimeOfDay.fromDateTime(schedule.endDate!);
        }
        
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

   Future<void> _pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // 允许编辑过去一年的事件
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickStartTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedStartTime = time;
        if (_selectedEndTime != null) {
          final startMinutes = time.hour * 60 + time.minute;
          final endMinutes = _selectedEndTime!.hour * 60 + _selectedEndTime!.minute;
          if (endMinutes < startMinutes) {
            _selectedEndTime = null;
          }
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
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
      setState(() => _selectedEndTime = time);
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

  Future<void> _updateSchedule() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedStartTime == null || _selectedBuilding == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date, time, and location.')),
        );
        return;
      }
      
      final startDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedStartTime!.hour, _selectedStartTime!.minute);
      DateTime? endDateTime;
      if (_selectedEndTime != null) {
        endDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedEndTime!.hour, _selectedEndTime!.minute);
      }

      final updatedSchedule = Schedule(
        id: widget.scheduleId,
        title: _titleInput.text,
        eventDate: startDateTime,
        endDate: endDateTime,
        locationName: _selectedBuilding!.roomName,
        userId: _currentSchedule!.userId, 
      );
      
      try {
        await _firestoreService.updateSchedule(updatedSchedule);
        if (mounted) {
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
        appBar: null, body: Center(child: CircularProgressIndicator()),
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
          child: Column(
            children: [
              Expanded(
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
              // Three listtiles for date, start time, and end time
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Date'),
                subtitle: Text(_selectedDate == null ? 'Select Date' : DateFormat.yMMMd().format(_selectedDate!)),
                onTap: _pickDate,
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: const Icon(Icons.access_time_outlined),
                title: const Text('Start Time'),
                subtitle: Text(_selectedStartTime == null ? 'Select Start Time' : _selectedStartTime!.format(context)),
                onTap: _pickStartTime,
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: const Icon(Icons.timelapse_outlined),
                title: const Text('End Time (Optional)'),
                subtitle: Text(_selectedEndTime == null ? 'Select End Time' : _selectedEndTime!.format(context)),
                onTap: _pickEndTime,
                enabled: _selectedStartTime != null,
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
                  onPressed: _updateSchedule,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Update'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Directly exit the edit screen without saving changes
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

  @override
  void dispose() {
    _titleInput.dispose();
    _locationInput.dispose();
    super.dispose();
  }
}