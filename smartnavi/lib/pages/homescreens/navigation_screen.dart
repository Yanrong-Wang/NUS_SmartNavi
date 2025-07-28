import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../services/find_bus.dart';
import '../../services/arrive_time.dart';

@RoutePage()
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final TextEditingController _startStationController = TextEditingController();
  final TextEditingController _endStationController = TextEditingController();

  List<String> _allStationNames = [];
  bool _isFetchingStations = true;
  bool _isLoading = false;

  // Use a list to store route results
  List<RouteResult> _routeResults = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    setState(() {
      _isFetchingStations = true;
    });

    try {
      final String data = await rootBundle.loadString('assets/venues.json');
      final Map<String, dynamic> jsonData = json.decode(data);
      _allStationNames = jsonData.keys.map((e) => e.toString()).toList();

      print('Successfully loaded ${_allStationNames.length} stations');
      // Print the first 10 stations for debugging
      print('First 10 stations: ${_allStationNames.take(10).toList()}');
      // Check if any station starts with 'S'
      final sStations = _allStationNames
          .where((name) => name.toLowerCase().startsWith('s'))
          .toList();
      print('Stations starting with S: $sStations');
    } catch (e) {
      print('Error loading stations: $e');
      _allStationNames = [];
    } finally {
      setState(() {
        _isFetchingStations = false;
      });
    }
  }

  Future<void> _performSearch() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _routeResults.clear();
      _errorMessage = null;
    });

    final start = _startStationController.text.trim();
    final end = _endStationController.text.trim();

    if (start.isEmpty || end.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both start and end station.';
        _isLoading = false;
      });
      return;
    }

    try {
      final busService = BusService();
      final routes = await busService.findVenueRoutes(start, end);

      if (routes.isEmpty) {
        setState(() {
          _errorMessage = 'No direct bus route found.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _routeResults = routes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Search failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _startStationController.dispose();
    _endStationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Search'), centerTitle: true),
      body: _isFetchingStations
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Start Station Autocomplete Field
                  _buildAutocompleteField(
                    controller: _startStationController,
                    labelText: 'Start Station',
                    hintText: 'e.g., S17',
                  ),
                  const SizedBox(height: 16),

                  // End Station Autocomplete Field
                  _buildAutocompleteField(
                    controller: _endStationController,
                    labelText: 'End Station',
                    hintText: 'e.g., UTown',
                  ),
                  const SizedBox(height: 24),

                  // Search Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _performSearch,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Search', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 32),

                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Show Route Results
                  if (_routeResults.isNotEmpty) _buildRouteResults(),
                ],
              ),
            ),
    );
  }

  // build the route results section
  Widget _buildRouteResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Routes (${_routeResults.length})',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _routeResults.length,
          itemBuilder: (context, index) {
            final result = _routeResults[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Show route ID with a colored circle
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          result.routeId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Show route information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show start and end bus stops behind each route
                          Text(
                            'Bus Route ${result.routeId} (${result.startStop} → ${result.endStop})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${result.stops} stops',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // A helper method to build the autocomplete text field
  Widget _buildAutocompleteField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text.trim();
        print('Autocomplete query: "$query"');

        if (query.isEmpty) {
          return const Iterable<String>.empty();
        }

        final filteredOptions = _allStationNames.where((String option) {
          return option.toLowerCase().contains(query.toLowerCase());
        }).toList();

        print('Found ${filteredOptions.length} options for "$query"');
        print('Options: ${filteredOptions.take(5).toList()}');

        return filteredOptions;
      },

      optionsViewBuilder: (context, onSelected, options) {
        final optionsList = options.toList();

        if (optionsList.isEmpty && controller.text.isNotEmpty) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: const ListTile(
                  title: Text('No station found.'),
                  leading: Icon(Icons.search_off),
                ),
              ),
            ),
          );
        }

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: optionsList.length,
                itemBuilder: (context, index) {
                  final option = optionsList[index];
                  return ListTile(
                    dense: true,
                    title: Text(option, style: const TextStyle(fontSize: 16)),
                    leading: const Icon(Icons.location_on, size: 20),
                    onTap: () {
                      onSelected(option);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },

      onSelected: (String selection) {
        controller.text = selection;
        print('Selected: $selection');
      },

      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController fieldController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return TextField(
              controller: controller,
              focusNode: fieldFocusNode,
              onChanged: (value) {
                print('TextField changed: "$value"');
              },
              decoration: InputDecoration(
                labelText: labelText,
                hintText: hintText,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
            );
          },
    );
  }
}
