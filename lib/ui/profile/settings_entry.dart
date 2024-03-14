import 'package:average_holiday_rate_pay/models/settings_model.dart';
import 'package:average_holiday_rate_pay/providers/auth_provider.dart';
import 'package:average_holiday_rate_pay/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsEntry extends ConsumerStatefulWidget {
  const SettingsEntry({super.key});

  @override
  ConsumerState<SettingsEntry> createState() => _SettingsEntryState();
}

class _SettingsEntryState extends ConsumerState<SettingsEntry> {
  final PageController _pageController = PageController();
  final TextEditingController _firstTextFieldController = TextEditingController();
  final TextEditingController _secondTextFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final user = ref.watch(authStateNotifierProvider)?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Prevent swiping
        children: [
          _buildFirstEntryPage(),
          _buildSecondEntryPage(user!),
        ],
      ),
    );
  }

  Widget _buildFirstEntryPage() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8,),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: TextField(
              controller: _firstTextFieldController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Rate per hour',
                filled: true,
                fillColor: Colors.blue[100],
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[100]!),
                  borderRadius: BorderRadius.circular(30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade800),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          IconButton(
            style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => const Color(0xFFBBDEFB))),
            icon: const Icon(Icons.arrow_forward),
            color: Colors.blue.shade800,
            onPressed: () async => _navigateToNextPage(_firstTextFieldController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondEntryPage(String user) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => const Color(0xFFBBDEFB))),
            icon: const Icon(Icons.arrow_back),
            color: Colors.blue.shade800,
            onPressed: () async => _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: TextField(
              controller: _secondTextFieldController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Contracted weekly hours',
                filled: true,
                fillColor: Colors.blue[100],
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[100]!),
                  borderRadius: BorderRadius.circular(30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade900),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => const Color(0xFFC8E6C9))),
            icon: const Icon(Icons.check),
            color: Colors.green[900],

            onPressed: () async => _submitValues(_secondTextFieldController.text, user),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToNextPage(String value) async {
    if (_isValidValue(value)) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showError();
    }
  }

  Future<void> _submitValues(String value, String user) async {
    if (_isValidValue(value)) {
      // Implement the submission logic here.
      debugPrint('First value: ${_firstTextFieldController.text}');
      debugPrint('Second value: ${_secondTextFieldController.text}');
      final newSettings =
      Settings(payRate: double.parse(_firstTextFieldController.text), contractedHours: double.parse(_secondTextFieldController.text));

      // Call updateUserSettings on the notifier to update the settings
      await ref
          .read(userSettingsProvider(user).notifier)
          .updateUserSettings(user, newSettings);
      await Future.microtask(() => context.go('/profile'));

    } else {
      _showError();
    }
  }

  bool _isValidValue(String value) {
    final enteredValue = double.tryParse(value);
    return enteredValue != null && enteredValue > 0;
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter a value bigger than 0.'),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstTextFieldController.dispose();
    _secondTextFieldController.dispose();
    super.dispose();
  }
}
