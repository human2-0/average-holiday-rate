import 'dart:math';

import 'package:average_holiday_rate_pay/providers/payslip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PayslipHistory extends ConsumerStatefulWidget {
  const PayslipHistory({super.key});

  @override
  ConsumerState<PayslipHistory> createState() => _PayslipHistoryState();
}

class _PayslipHistoryState extends ConsumerState<PayslipHistory> {
  int currentMonthIndex = 0; // Initialize with a default value
  bool isInitialLoad = true;

  String formatMonthYear(DateTime date) =>
      "${date.month.toString().padLeft(2, '0')}/${date.year}";

  @override
  Widget build(BuildContext context) {
// Ensure index stays within valid range

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

                    // Adjust initial month index to start from the last element
                    if (isInitialLoad && monthsList.isNotEmpty) {
                      currentMonthIndex = monthsList.length - 1;
                      isInitialLoad =
                          false; // Set flag to false after initial setup
                    }

                    final selectedMonth = monthsList.isNotEmpty
                        ? monthsList[currentMonthIndex]
                        : null;
                    final payslipsForCurrentMonth = payslips
                        .where(
                          (payslip) =>
                              formatMonthYear(payslip.startDate) ==
                              selectedMonth,
                        )
                        .toList();

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
                                  icon: const Icon(
                                    Icons.arrow_left,
                                    size: 30,
                                  ),
                                  onPressed: currentMonthIndex > 0
                                      ? () => setState(
                                            () => currentMonthIndex--,
                                          )
                                      : null,
                                  disabledColor: Colors.grey,
                                ),
                                Text(
                                  monthsList.isNotEmpty
                                      ? monthsList[currentMonthIndex]
                                      : 'No Data',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_right,
                                    size: 30,
                                  ),
                                  onPressed:
                                      currentMonthIndex < monthsList.length - 1
                                          ? () => setState(
                                                () => currentMonthIndex++,
                                              )
                                          : null,
                                  disabledColor: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: payslipsForCurrentMonth.length,
                              itemBuilder: (context, index) {
                                final payslip = payslipsForCurrentMonth[index];
                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.lightBlue[100],
                                  ),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: BorderSide(
                                          color: Colors.blueGrey.shade100,),
                                    ),
                                    tileColor: Colors.white,
                                    title: Text(
                                      ' Hours: ${payslip.hoursWorked}\n Bonuses: ${payslip.bonusesEarned}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    leading: Icon(Icons.access_time,
                                        color: Colors.lightBlue[400],),
                                    trailing: DecoratedBox(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(33),
                                            color: Colors.red[50],),
                                        child: IconButton(
                                          icon:
                                              const Icon(Icons.delete_outline),
                                          color: Colors.redAccent.shade200,
                                          onPressed: () async {
                                            await ref.read(payslipNotifierProvider.notifier).removePayslip(payslip, index);

                                            // After deletion, update UI accordingly
                                            setState(() {
                                              final payslips = ref.watch(payslipNotifierProvider); // Re-fetch the payslips
                                              final monthsList = payslips
                                                  .map((payslip) => formatMonthYear(payslip.startDate))
                                                  .toSet()
                                                  .toList();

                                              // Check if the currentMonthIndex is now out of bounds
                                              if (currentMonthIndex >= monthsList.length) {
                                                currentMonthIndex = max(0, monthsList.length - 1); // Adjust index or reset to 0 if list is empty
                                              }

                                              // This will also handle the isInitialLoad reset if necessary
                                              isInitialLoad = monthsList.isEmpty;
                                            });
                                          },
                                        ),),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10,),
                                  ),
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
