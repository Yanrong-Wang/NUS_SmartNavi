import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

@RoutePage()
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final TextEditingController _startStationController = TextEditingController();
  final TextEditingController _endStationController = TextEditingController();
  final FirestoreService _firebaseService = FirestoreService();

  List<String> _allStationNames = [];
  bool _isFetchingStations = true;
  bool _isLoading = false;
  String? _searchResult;

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    setState(() {
      _isFetchingStations = true;
    });
    _allStationNames = await _firebaseService.getStationNames();
    setState(() {
      _isFetchingStations = false;
    });
  }

  Future<void> _performSearch() async {
    // Search by start and end stations
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _searchResult = null;
    });
    final result = await _firebaseService.searchRoute(
      _startStationController.text,
      _endStationController.text,
    );
    setState(() {
      _searchResult = result;
      _isLoading = false;
    });
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
      // Show a loading indicator while fetching station names
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
                    hintText: 'e.g., LT27',
                  ),
                  const SizedBox(height: 16),

                  // End Station Autocomplete Field
                  _buildAutocompleteField(
                    controller: _endStationController,
                    labelText: 'End Station',
                    hintText: 'e.g., Utown',
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
                  if (_searchResult != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _searchResult!,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  // A helper method to build the autocomplete text field
  Widget _buildAutocompleteField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
  }) {
    return Autocomplete<String>(
      // 1. optionsBuilder
      optionsBuilder: (TextEditingValue textEditingValue) {
        // If the input is empty, return an empty list.
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        // Otherwise, filter the station names based on the input.
        return _allStationNames.where((String option) {
          // Use the `toLowerCase` method to make the search not case-insensitive.
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },

      // Builder is used to display the suggestions.
      optionsViewBuilder: (context, onSelected, options) {
        // If there are no options, show a message.
        if (options.isEmpty && controller.text.isNotEmpty) {
          return Material(
            elevation: 4.0,
            child: ListTile(title: Text('No station found.')),
          );
        }
        // Otherwise, show the list of options.
        return Material(
          elevation: 4.0,
          child: ListView(
            padding: EdgeInsets.zero,
            children: options
                .map(
                  (option) => ListTile(
                    title: Text(option),
                    onTap: () {
                      onSelected(option);
                    },
                  ),
                )
                .toList(),
          ),
        );
      },

      // 2. onSelected: when an option is selected.
      onSelected: (String selection) {
        controller.text = selection;
        debugPrint('You just selected $selection');
      },

      // 3. fieldViewBuilder to customize the text field.
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController fieldController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            // Use the provided controller instead of the one from Autocomplete.
            return TextField(
              controller: controller, // Use the controller we passed in
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                labelText: labelText,
                hintText: hintText,
                border: const OutlineInputBorder(),
              ),
            );
          },
    );
  }
}
