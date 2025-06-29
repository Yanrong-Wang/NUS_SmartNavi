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

  // 这个方法保持不变
  Future<void> _performSearch() async {
    // 我们使用 Controller 中的文本进行搜索
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
      // 如果我们还在获取站点列表，就显示一个加载动画
      body: _isFetchingStations
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAutocompleteField(
                    controller: _startStationController,
                    labelText: 'Start Station',
                    hintText: 'e.g., LT27',
                  ),
                  const SizedBox(height: 16),

                  // --- 终点站的自动补全输入框 ---
                  _buildAutocompleteField(
                    controller: _endStationController,
                    labelText: 'End Station',
                    hintText: 'e.g., Utown',
                  ),
                  const SizedBox(height: 24),

                  // 查询按钮和结果显示区域保持不变
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
                        color: Colors.blue.withOpacity(0.1),
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

  // --- 创建一个辅助方法来避免代码重复 ---
  Widget _buildAutocompleteField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
  }) {
    return Autocomplete<String>(
      // 1. optionsBuilder: 这是实现过滤的核心。
      optionsBuilder: (TextEditingValue textEditingValue) {
        // 如果输入框是空的，就不显示任何建议。
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        // 过滤所有站点的列表。
        return _allStationNames.where((String option) {
          // 使用 toLowerCase() 来实现不区分大小写的搜索
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },

      // 这个 builder 用于构建建议列表的视图。
      // 我们自定义它来显示“未找到”的消息。
      optionsViewBuilder: (context, onSelected, options) {
        // 如果 options 列表为空 (意味着没有匹配项)，并且用户已经输入了文字
        if (options.isEmpty && controller.text.isNotEmpty) {
          return Material(
            elevation: 4.0,
            child: ListTile(title: Text('No station found.')),
          );
        }
        // 否则，显示正常的建议列表。
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

      // 2. onSelected: 当用户从建议列表中选择一项时被调用。
      onSelected: (String selection) {
        // 当选项被选中时，更新我们自己的 Controller 的文本。
        controller.text = selection;
        debugPrint('You just selected $selection');
      },

      // 3. fieldViewBuilder: 用于自定义输入框本身的外观。
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController fieldController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            // Autocomplete 内部有自己的 controller (fieldController),
            // 但为了能在外部通过"Search"按钮获取值，我们在这里使用我们自己传入的 controller。
            return TextField(
              controller: controller, // 使用我们传入的 controller
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
