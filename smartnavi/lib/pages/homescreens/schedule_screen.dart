import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/schedule_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/router.gr.dart';

@RoutePage()
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Stream<List<Schedule>> _schedulesStream;
  List<Schedule> _allSchedules = [];
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _schedulesStream = _firestoreService.getSchedules();
  }

  List<Schedule> _getEventsForDay(DateTime day, List<Schedule> schedules) {
    return schedules.where((event) => isSameDay(event.eventDate, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
      ),
      body: StreamBuilder<List<Schedule>>(
        stream: _schedulesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            _allSchedules = [];
             return _buildCalendarWithNoData();
          }
          
          _allSchedules = snapshot.data!;
          final selectedDayEvents = _getEventsForDay(_selectedDay!, _allSchedules);

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: (day) => _getEventsForDay(day, _allSchedules),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: ListView.builder(
                  itemCount: selectedDayEvents.length,
                  itemBuilder: (context, index) {
                    final event = selectedDayEvents[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        title: Text(event.title),
                        subtitle: Text(event.locationName),
                        trailing: Text(DateFormat.jm().format(event.eventDate)),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.router.push(const AddScheduleRoute());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
    
  // Helper widget for when there's no data, to still show the calendar
  Widget _buildCalendarWithNoData() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
        ),
        const Expanded(
          child: Center(
            child: Text("No schedules yet. Tap '+' to add one!"),
          ),
        ),
      ],
    );
  }
}
