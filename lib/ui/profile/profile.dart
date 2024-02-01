import 'package:average_holiday_rate_pay/customs/toast.dart';
import 'package:average_holiday_rate_pay/models/settings.dart';
import 'package:average_holiday_rate_pay/providers/auth.dart';
import 'package:average_holiday_rate_pay/ui/profile/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<ProfileScreen> {
  late TextEditingController _payRateController;
  late TextEditingController _contractedHoursController;
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    _payRateController = TextEditingController();
    _contractedHoursController = TextEditingController();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    _payRateController.dispose();
    _contractedHoursController.dispose();
    super.dispose();
  }

  Future<void> _showEditDialog(String user, Settings settings) async {
    _payRateController.text = settings.payRate.toString();
    _contractedHoursController.text = settings.contractedHours.toString();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close the dialog
      builder: (context) => AlertDialog(
        title: const Text('Edit Settings'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextFormField(
                controller: _payRateController,
                decoration: const InputDecoration(labelText: 'Pay Rate'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _contractedHoursController,
                decoration:
                    const InputDecoration(labelText: 'Contracted Hours'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              final payRate = double.tryParse(_payRateController.text) ?? 0;
              final contractedHours =
                  double.tryParse(_contractedHoursController.text) ?? 0;

              // Create a new Settings object with updated values
              final newSettings =
                  Settings(payRate: payRate, contractedHours: contractedHours);

              // Call updateUserSettings on the notifier to update the settings
              await ref
                  .read(userSettingsProvider(user).notifier)
                  .updateUserSettings(user, newSettings);

              if (mounted) {
                Navigator.of(context).pop();
                CustomToast( 'Settings updated',
                  const Icon(Icons.done_outline_rounded), Colors.greenAccent,)
                    .showCustomToast();
              }

            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateNotifierProvider);

    if (user == null) {
      // User not signed in, show the LoginScreen
      return const LoginScreen();
    } else {
      final settingsState = ref.watch(userSettingsProvider(user.uid));

      Widget content;
      if (settingsState.isLoading) {
        content = const CircularProgressIndicator();
      } else if (settingsState.error != null) {
        content = Text('Error: ${settingsState.error}');
      } else if (settingsState.settings != null) {
        final settings = settingsState.settings!;
        _payRateController.text = settings.payRate.toString();
        _contractedHoursController.text = settings.contractedHours.toString();
        content = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4, // Adds shadow under the card
              margin: const EdgeInsets.all(16), // Adds margin around the card
              child: Padding(
                padding:
                    const EdgeInsets.all(16), // Adds padding inside the card
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Makes the card wrap its content
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.photoURL ??
                          'default_avatar_url',), // Use user's photoURL for the avatar
                      radius: 40, // Size of the avatar
                    ),
                    const SizedBox(
                        height: 16,), // Adds spacing between avatar and text
                    Text(
                      'Welcome, ${user.displayName ?? user.email ?? 'User'}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,), // Makes text larger and bold
                    ),
                    const SizedBox(height: 8), // Adds spacing between texts
                    Text(
                      'Email: ${user.email ?? 'N/A'}',
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight:
                              FontWeight.bold,), // Grey color for less emphasis
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pay Rate:'),
                        Text('£${settings.payRate.toStringAsFixed(2)} /hr',
                            style: const TextStyle(
                                fontWeight: FontWeight
                                    .bold,),), // Formats pay rate to 2 decimal places
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Contracted Hours:'),
                        Text('${settings.contractedHours} hours/week',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),),
                      ],
                    ),
                    const SizedBox(
                        height: 16,), // Adds spacing before the button
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async =>
                            _showEditDialog(user.uid, settings),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ... other UI elements ...
          ],
        );
      } else {
        content = const Text('No settings available');
      }

      return Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 8, 0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  color: Colors.lightBlue[100],
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await ref
                        .read(authStateNotifierProvider.notifier)
                        .signOut();
                    if (mounted){
                      CustomToast('You have been logged out',
                        const Icon(Icons.flight_takeoff), Colors.greenAccent[100]!,)
                          .showCustomToast();
                    }
                    // Navigate to login screen or home screen as needed after sign out
                  },
                ),
              ),
            ),
          ],
        ),
        body: Center(
          child: content,
        ),
      );
    }
  }
}
