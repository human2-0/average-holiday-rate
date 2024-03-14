import 'dart:math';

import 'package:average_holiday_rate_pay/customs/toast_widget.dart';
import 'package:average_holiday_rate_pay/models/payslip_model.dart';
import 'package:average_holiday_rate_pay/providers/payslip_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PayslipHistory extends ConsumerStatefulWidget {
  const PayslipHistory({super.key});

  @override
  ConsumerState<PayslipHistory> createState() => _PayslipHistoryState();
}

class _PayslipHistoryState extends ConsumerState<PayslipHistory> {
  late final PageController _pageController;
  List<String> monthsList = [];
  bool isInitialLoad = true;

  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Assume this is filled appropriately elsewhere
    monthsList = [];
    // This could be a place where you calculate currentMonthIndex based on your conditions
    currentMonthIndex = max(0, monthsList.length - 1);
    _currentPageIndex = currentMonthIndex;
    _pageController = PageController(initialPage: _currentPageIndex);

    _pageController.addListener(() {
      final newIndex = _pageController.page!.round();
      if (newIndex != _currentPageIndex) {
        setState(() {
          _currentPageIndex = newIndex;
          // Optionally, synchronize _currentPageIndex with currentMonthIndex if needed
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String formatMonthYear(DateTime date) {
    return DateFormat('MMMM/yyyy').format(date);
  }

  int currentMonthIndex = 0;

  Future<void> _showEditDialog(Payslip payslip) async {
    var localPayRate = payslip.payRate.toString();
    var localBasePay = payslip.basePay.toString();
    var localBonusEarned = payslip.bonusesEarned.toString();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close the dialog
      builder: (context) => AlertDialog(
        title: const Text('Edit payslip'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextFormField(
                initialValue: localBasePay,
                decoration:
                    const InputDecoration(labelText: 'Contracted hours'),
                keyboardType: TextInputType.number,
                onChanged: (value) => localBasePay = value,
              ),
              TextFormField(
                initialValue: localBonusEarned,
                decoration: const InputDecoration(labelText: 'Bonus earned'),
                keyboardType: TextInputType.number,
                onChanged: (value) => localBonusEarned = value,
              ),
              TextFormField(
                initialValue: localPayRate,
                decoration: const InputDecoration(labelText: 'Pay rate'),
                keyboardType: TextInputType.number,
                onChanged: (value) => localPayRate = value,
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
              // Use local variables to update settings
              final payRate = double.tryParse(localPayRate) ?? 0;
              final basePay = double.tryParse(localBasePay) ?? 0;
              final bonusesEarned = double.tryParse(localBonusEarned) ?? 0;
              final updatedPayslip = payslip.copyWith(
                basePay: basePay,
                payRate: payRate,
                bonusesEarned: bonusesEarned,
              );
              await ref
                  .read(payslipNotifierProvider.notifier)
                  .editPayslip(updatedPayslip);

              await Future.microtask(
                () => showToast(
                  context,
                  'Edited successfully',
                  Colors.greenAccent[100]!,
                  Colors.green[900]!,
                  icon: Icons.edit,
                ),
              );

              await Future.microtask(() => context.pop());
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(33),
                color: Colors.lightBlue[100],
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Consumer(
                  builder: (context, ref, child) {
                    final payslips = ref.watch(payslipNotifierProvider);

                    // Create a sorted list of unique month/year strings
                    final monthsList = payslips
                        .map((payslip) => formatMonthYear(payslip.startDate))
                        .toSet()
                        .toList();

                    // Sort monthsList if needed, e.g., by descending order to ensure the latest month comes first

                    // Check for initial load to set the latest month

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(33),
                                topRight: Radius.circular(33),
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(5),
                              ),
                              color: Colors.lightBlue[100],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Left arrow button - moves to more recent payslips
                                IconButton(
                                  icon: const Icon(Icons.arrow_left, size: 30),
                                  onPressed: _currentPageIndex > 0
                                      ? () async {
                                          await _pageController.previousPage(
                                            duration: const Duration(
                                                milliseconds: 200,),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      : null,
                                  disabledColor: Colors.grey,
                                ),
                                Text(
                                  monthsList.isNotEmpty
                                      ? ' ${monthsList[_currentPageIndex]}'
                                      : 'No Data',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_right, size: 30),
                                  onPressed:
                                      _currentPageIndex < monthsList.length - 1
                                          ? () async {
                                              await _pageController.nextPage(
                                                duration: const Duration(
                                                    milliseconds: 300,),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                          : null,
                                  disabledColor: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.40,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5),
                                bottomLeft: Radius.circular(33),
                                bottomRight: Radius.circular(33),
                              ),
                            ),
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: monthsList.length,
                              onPageChanged: (index) {
                                // Update the state to reflect the current page index
                                setState(() {
                                  _currentPageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                final selectedMonth = monthsList[index];
                                final payslipsForCurrentMonth = payslips
                                    .where(
                                      (payslip) =>
                                          formatMonthYear(payslip.startDate) ==
                                          selectedMonth,
                                    )
                                    .toList();
                                if (isInitialLoad && monthsList.isNotEmpty) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    _pageController
                                        .jumpToPage(monthsList.length - 1);
                                    setState(() {
                                      isInitialLoad = false;
                                    });
                                  });
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: payslipsForCurrentMonth.length,
                                  itemBuilder: (context, index) {
                                    final payslip =
                                        payslipsForCurrentMonth[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 0, 4),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          color: Colors.lightBlue[100],
                                        ),
                                        child: ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            side: BorderSide(
                                              color: Colors.blueGrey.shade100,
                                            ),
                                          ),
                                          tileColor: Colors.white,
                                          leading: Icon(
                                            Icons.access_time,
                                            color: Colors.lightBlue[400],
                                          ),
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(8),
                                                  ),
                                                  color: Colors.blue[50],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Base pay: £${formatNumbers(payslip.basePay)}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(8),
                                                  ),
                                                  color: Colors.green[100],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Bonuses: £${formatNumbers(payslip.bonusesEarned)}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green[800],
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(8),
                                                  ),
                                                  color: Colors.deepPurple[100],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Pay rate: £${formatNumbers(payslip.payRate)}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors
                                                          .deepPurple[900],
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateColor
                                                          .resolveWith(
                                                    (states) => const Color(
                                                      0xFFFFF59D,
                                                    ),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.mode_edit_outline,
                                                ),
                                                color: Colors.yellow[800],
                                                onPressed: () async {
                                                  await _showEditDialog(
                                                    payslip,
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateColor
                                                          .resolveWith(
                                                    (states) => const Color(
                                                      0xFFFFEBEE,
                                                    ),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                                color:
                                                    Colors.redAccent.shade200,
                                                onPressed: () async {
                                                  await ref
                                                      .read(
                                                        payslipNotifierProvider
                                                            .notifier,
                                                      )
                                                      .removePayslip(
                                                        payslip,
                                                        index,
                                                      );

                                                  // Re-fetch the payslips to update the UI correctly.
                                                  // This could be optimized if the provider automatically updates its listeners upon deletion.
                                                  final updatedPayslips =
                                                      ref.read(
                                                    payslipNotifierProvider,
                                                  );
                                                  final updatedMonthsList =
                                                      updatedPayslips
                                                          .map(
                                                            (payslip) =>
                                                                formatMonthYear(
                                                              payslip.startDate,
                                                            ),
                                                          )
                                                          .toSet()
                                                          .toList();

                                                  if (currentMonthIndex >=
                                                      updatedMonthsList
                                                          .length) {
                                                    currentMonthIndex = max(
                                                      0,
                                                      updatedMonthsList.length -
                                                          1,
                                                    );
                                                  }

                                                  setState(() {
                                                    // State update to trigger UI rebuild with the updated list and index.
                                                    isInitialLoad =
                                                        updatedMonthsList
                                                            .isEmpty;
                                                  });
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                          (timeStamp) {
                                                    showToast(
                                                      context,
                                                      'Deletion completed',
                                                      Colors.greenAccent,
                                                      Colors.green[900]!,
                                                    );
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String formatNumbers(double number) {
  // Check if the number is an integer
  if (number == number.toInt()) {
    // If it is, return it as an integer string
    return number.toInt().toString();
  } else {
    // If it's not, return it as a double with one decimal place
    // Only if needed, otherwise return the original double converted to string
    return number.toStringAsFixed(1).replaceAll('.0', '');
  }
}
