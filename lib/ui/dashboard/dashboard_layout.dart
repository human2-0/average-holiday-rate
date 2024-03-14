import 'package:average_holiday_rate_pay/providers/holiday_rate_provider.dart';
import 'package:average_holiday_rate_pay/ui/dashboard/historical_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardChartsScreen extends ConsumerStatefulWidget {
  const DashboardChartsScreen({super.key});

  @override
  ConsumerState<DashboardChartsScreen> createState() =>
      _DashboardChartsScreenState();
}

class _DashboardChartsScreenState extends ConsumerState<DashboardChartsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future.microtask(
      () async => ref
          .read(holidayRateNotifierProvider.notifier)
          .fetchHistoricalHolidayRates(),
    );
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.lightBlue[100],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.lightBlueAccent[100],
                    ),
                    child: const Text("This month's rate"),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.lightBlue[400],
                      ),
                      child: Consumer(
                        builder: (context, ref, child) {
                          final holidayRate = ref
                              .watch(holidayRateNotifierProvider)
                              .historicalHolidayRates
                              ?.values
                              .first
                              .toStringAsFixed(2);
                          return Text('£$holidayRate');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Column(children: [LineChartSample2()]),
        ],
      ),
    );
  }
}
