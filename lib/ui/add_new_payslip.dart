import 'package:average_holiday_rate_pay/customs/toast_widget.dart';
import 'package:average_holiday_rate_pay/models/payslip_model.dart';
import 'package:average_holiday_rate_pay/providers/auth_provider.dart';
import 'package:average_holiday_rate_pay/providers/payslip_provider.dart';
import 'package:average_holiday_rate_pay/providers/settings_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  double? _basePay;
  double? _bonusesEarned;
  double? _payRate;
  late PickerDateRange _selectedRange = PickerDateRange(
    DateTime.now(),
    DateTime.now(),
  );
  late DateRangePickerView dateSelectionType = DateRangePickerView.year;
  late DateRangePickerController _datePickerController =
      DateRangePickerController();

  Key _pickerKey = UniqueKey();

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

  Future<void> _addPayslip(BuildContext currentContext) async {
    // Ensure that start and end dates are set
    if (_startDate == null || _endDate == null) {
      showToast(
        currentContext,
        'Please, select the date.',
        Colors.yellow[100]!,
        Colors.yellow[900]!,
      );
    }

    // Create a new Payslip with the selected dates and entered values
    final newPayslip = Payslip(
      startDate: _startDate!,
      endDate: _endDate!,
      basePay: _basePay!,
      bonusesEarned: _bonusesEarned!,
      payRate: _payRate!,
    );

    // Add the Payslip and handle the response
    try {
      await ref.read(payslipNotifierProvider.notifier).addPayslip(newPayslip);
    } on FormatException catch (error) {
      debugPrint(error.message);
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showToast(
        context,
        'The payslip has been added.',
        Colors.greenAccent[100]!,
        Colors.green[900]!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authStateNotifierProvider)?.uid;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20), // Adjust the radius as needed
              bottomRight: Radius.circular(20), // Adjust the radius as needed
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter, // Gradient starts at the top
              end: Alignment.bottomCenter, // And ends at the bottom
              colors: [
                Colors.blue[50]!, // Lighter blue at the top
                Colors.blue[100]!, // Darker blue towards the bottom
              ],
            ),
          ),
        ),
        title: Text(
          'Add new payslip',
          style: TextStyle(color: Colors.blueGrey.shade900),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue[900], size: 32),
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
                  decoration: InputDecoration(
                    labelText: 'Base pay',
                    hintText: 'Enter sum of all your basic payments',
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
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _basePay = double.tryParse(value ?? '');
                  },
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) {
                      return 'Please enter any amount above 0.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8,),
                // Bonuses Earned Input
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Bonuses earned', // Use labelText to enable floating label behavior
                    hintText: 'Enter bonuses earned this month', // hintText is shown when the field is empty and not focused
                    filled: true,
                    alignLabelWithHint: true,
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
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _bonusesEarned = double.tryParse(value ?? '');
                  },
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) {
                      return 'Please enter any amount above 0.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8,),
                TextFormField(
                  controller: TextEditingController(
                    text: ref
                        .read(userSettingsProvider(userId!))
                        .settings
                        ?.payRate
                        .toString(),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Pay rate',
                    hintText: 'Pay rate for selected month',
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
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _payRate = double.tryParse(value ?? '1');
                  },
                  validator: (value) {
                    if (value == null ||
                        double.tryParse(value) == null ||
                        double.tryParse(value) == 0) {
                      return 'Please enter a number bigger than 0.';
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
                      await _addPayslip(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      EnumProperty<DateRangePickerView>(
        'dateSelectionType',
        dateSelectionType,
      ),
    );
  }
}
