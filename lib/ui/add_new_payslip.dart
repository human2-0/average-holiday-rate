import 'package:average_holiday_rate_pay/customs/toast.dart';
import 'package:average_holiday_rate_pay/models/payslip.dart';
import 'package:average_holiday_rate_pay/providers/auth.dart';
import 'package:average_holiday_rate_pay/providers/payslip.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AddPayslipScreen extends ConsumerStatefulWidget {
  const AddPayslipScreen({super.key});

  @override
  _AddPayslipScreenState createState() => _AddPayslipScreenState();
}

class _AddPayslipScreenState extends ConsumerState<AddPayslipScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  double? _hoursWorked;
  double? _bonusesEarned;
  late PickerDateRange _selectedRange = PickerDateRange(
    DateTime.now(),
    DateTime.now(),
  );
  late DateRangePickerView dateSelectionType = DateRangePickerView.year;
  late DateRangePickerController _datePickerController =
      DateRangePickerController();

  Key _pickerKey = UniqueKey();
  late FToast fToast;

  void _updateControllerAndView(DateRangePickerView newViewType) {
    setState(() {
      dateSelectionType = newViewType;

      // Recreate the controller with the current display date
      final currentDisplayDate =
          _datePickerController.displayDate ?? DateTime.now();
      _datePickerController = DateRangePickerController();
      _datePickerController.displayDate = currentDisplayDate;

      _pickerKey =
          UniqueKey(); // Update the key to force rebuild of the date picker
    });
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      final range = args.value as PickerDateRange;
      setState(() {
        _selectedRange = range;
        _startDate = range.startDate;
        _endDate = range.endDate;
      });
    } else if (args.value is DateTime) {
      // When a single date (month) is selected
      final selectedMonth = args.value as DateTime;
      setState(() {
        _startDate = DateTime(selectedMonth.year, selectedMonth.month);
        _endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
        _selectedRange = PickerDateRange(_startDate, _endDate);
      });
    } else {
      // Handle other cases if needed
    }
  }



  Future<void> _addPayslip() async {
    // Ensure that start and end dates are set
    if (_startDate == null || _endDate == null) {
      CustomToast('Please select the date range',
        const Icon(Icons.error_outlined), Colors.red[100]!,)
          .showCustomToast();
      return;
    }

    // Ensure hours worked and bonuses are set
    if (_hoursWorked == null || _bonusesEarned == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly')),
      );
      return;
    }

    final userId = ref.read(authStateNotifierProvider)?.uid;

    // Ensure that the user is logged in (i.e., userId is not null)
    if (userId == null || userId.isEmpty) {
      CustomToast('Please sign in or create an account',
        const Icon(Icons.insert_emoticon_outlined), Colors.yellowAccent,)
          .showCustomToast();
      return;
    }

    // Create a new Payslip with the selected dates and entered values
    final newPayslip = Payslip(
      startDate: _startDate!,
      endDate: _endDate!,
      hoursWorked: _hoursWorked!,
      bonusesEarned: _bonusesEarned!,
    );

    // Add the Payslip and handle the response
    try {
      await ref.read(payslipRepositoryProvider).addPayslip(newPayslip);
      if (mounted) {
        CustomToast('Payslip added successfully', const Icon(Icons.done_outline_rounded), Colors.greenAccent)
            .showCustomToast();
      }
    } on FormatException catch (error) {
      if (mounted) {
        CustomToast('Error adding payslip: ${error.message}',
          const Icon(Icons.error_outlined), Colors.red[400]!,)
            .showCustomToast();
      }
    }
  }



  @override
  Widget build(BuildContext context)  {

    return  Scaffold(
      appBar: AppBar(
        title: const Text('Add payslip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.calendar_today,
                        color: dateSelectionType == DateRangePickerView.year
                            ? Colors.blue // Highlight color for selected
                            : Colors.black, // Default color
                      ),
                      onPressed: () =>
                          _updateControllerAndView(DateRangePickerView.year),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.calendar_view_month,
                        color: dateSelectionType == DateRangePickerView.month
                            ? Colors.blue // Highlight color for selected
                            : Colors.black, // Default color
                      ),
                      onPressed: () =>
                          _updateControllerAndView(DateRangePickerView.month),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.1,
                  child: dateSelectionType == DateRangePickerView.year
                      ? Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_left),
                              onPressed: () {
                                setState(() {
                                  _datePickerController.displayDate = DateTime(
                                    _datePickerController.displayDate!.year - 1,
                                  );
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_right),
                              onPressed: () {
                                setState(() {
                                  _datePickerController.displayDate = DateTime(
                                    _datePickerController.displayDate!.year + 1,
                                  );
                                });
                              },
                            ),
                          ],
                        )
                      : null, // When not in year view, display nothing
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: SfDateRangePicker(
                    key: _pickerKey,
                    allowViewNavigation: false,
                    view: dateSelectionType,
                    selectionMode: dateSelectionType == DateRangePickerView.year
                        ? DateRangePickerSelectionMode.single
                        : DateRangePickerSelectionMode.range,
                    onSelectionChanged: _onSelectionChanged,
                    initialSelectedRange: _selectedRange,
                    controller: _datePickerController,
                  ),
                ),
                // Hours Worked Input
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Hours Worked'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _hoursWorked = double.tryParse(value ?? '');
                  },
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                // Bonuses Earned Input
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Bonuses Earned',
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _bonusesEarned = double.tryParse(value ?? '');
                  },
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Submit Button
                ElevatedButton(
                  child: const Text('Add Payslip'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      await _addPayslip();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );}
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<DateRangePickerView>('dateSelectionType', dateSelectionType));
  }
}
