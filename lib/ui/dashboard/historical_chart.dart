import 'dart:math';

import 'package:average_holiday_rate_pay/providers/holiday_rate_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class LineChartSample2 extends ConsumerStatefulWidget {
  const LineChartSample2({super.key});

  @override
  ConsumerState<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends ConsumerState<LineChartSample2> {
  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];

  bool showAvg = false;
  late double averageRate;
  int viewportSize = 5; // Number of spots to show at once
  int startIndex = 0; // Will be dynamically calculated based on data

  @override
  void initState() {
    super.initState();
  }

  void moveViewport(int direction) {
    final historicalRatesMap =
        ref.watch(holidayRateNotifierProvider).historicalHolidayRates ?? {};
    final maxIndex = historicalRatesMap.length - viewportSize;
    startIndex += direction;
    if (startIndex < 0) {
      startIndex = 0;
    } else if (startIndex > maxIndex) {
      startIndex = maxIndex;
    }
    setState(() {}); // Trigger a rebuild to update the chart
  }

  @override
  Widget build(BuildContext context) {
    // This block of code sets properly the startIndex. Other attempts caused issue with ending always on startIndex 0.
    ref.listen<HolidayRateState>(holidayRateNotifierProvider, (_, state) {
      if (state.historicalHolidayRates != null) {
        final totalSpots = state.historicalHolidayRates!.length;
        setState(() {
          startIndex = max(0, totalSpots - viewportSize);
        });
      }
    });
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.5,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors
                    .lightBlue[50], // Background color of the chart container
                borderRadius: BorderRadius.circular(18), // Rounded corners
                border: Border.all(
                  color:
                      Colors.blue[50]!, // Change this to desired border color
                  width: 2, // Border thickness
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 22,
                  left: 22,
                  top: 24,
                  bottom: 22,
                ),
                child: LineChart(
                  mainData(),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () => moveViewport(-1),
              child: const Icon(Icons.arrow_left),
            ),
            ElevatedButton(
              onPressed: () => moveViewport(1),
              child: const Icon(Icons.arrow_right),
            ),
          ],
        ),
      ],
    );
  }

  List<FlSpot> getSpotsFromRates(Map<String, double> historicalRates) {
    final spots = <FlSpot>[];
    final sortedKeys = historicalRates.keys.toList()..sort();
    for (var i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final rate = historicalRates[key];
      if (rate != null && rate.isFinite) {
        // Ensure rate is finite
        final roundedRate = double.parse(rate.toStringAsFixed(2));
        spots.add(FlSpot(i.toDouble(), roundedRate));
      }
    }
    return spots;
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final historicalRatesMap =
        ref.read(holidayRateNotifierProvider).historicalHolidayRates ?? {};
    final sortedKeys = historicalRatesMap.keys.toList()..sort();
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );

    var text = '';
    if (value.toInt() >= 0 && value.toInt() < sortedKeys.length) {
      final dateString = sortedKeys[value.toInt()];
      // Parse the dateString to a DateTime object
      final date = DateFormat('yyyy-MM').parse(dateString);
      // Format the date into "MMM/yy", which is the three first letters of the month name followed by the last two digits of the year
      text = DateFormat('MMM/yy').format(date);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }


  LineChartData mainData() {
    final historicalRatesMap =
        ref.watch(holidayRateNotifierProvider).historicalHolidayRates ?? {};
    final spots = getSpotsFromRates(historicalRatesMap);

    var minY = 0.0;
    var maxY = 100.0;
    if (spots.isNotEmpty) {
      minY = spots.map((spot) => spot.y).reduce(min);
      maxY = spots.map((spot) => spot.y).reduce(max);
    }

    // Ensure minY and maxY are finite
    minY = minY.isFinite ? minY : 0.0;
    maxY = maxY.isFinite ? maxY : 100.0;

    // Add diagnostic print statements

    // Calculate rangePadding safely
    const paddingFactor = 2;
    final rangePadding = (maxY - minY) * paddingFactor;

    final minX = startIndex.toDouble();
    var maxX = (startIndex + viewportSize).toDouble();
    maxX = maxX > spots.length ? spots.length.toDouble() : maxX;

    // Confirm minX, maxX, minY - rangePadding, maxY + rangePadding are finite
    if (!minX.isFinite ||
        !maxX.isFinite ||
        !(minY - rangePadding).isFinite ||
        !(maxY + rangePadding).isFinite) {
      // Consider setting default values or handling the error as appropriate
    }

    return LineChartData(
      gridData: FlGridData(
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 25,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            getTitlesWidget: (value, meta) {
              // Customize title widgets based on value
              final titleText = value.toStringAsFixed(
                2,
              ); // Format the value to string with 1 decimal place
              return Text(
                titleText,
                style: const TextStyle(
                  color: Color(0xff68737d),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
            reservedSize: 40, // Reserve space for the titles
            interval:
                1, // Interval at which to show the titles (customize as needed)
            // You can customize margin, textStyle, etc., as well
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: minX, // Adjusted to ensure there's always a buffer for visibility
      maxX: maxX - 1, // Adjusted similarly to minX
      minY: minY - rangePadding,
      maxY: maxY + rangePadding,

      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          isStrokeCapRound: true,
          barWidth: 5,
          dotData: FlDotData(
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
              radius: 8, // Dot size
              color: gradientColors.last
                  .withOpacity(0.9), // Dot color, customize as needed
              strokeWidth: 1.5, // Border width
              strokeColor: Colors.blue[300]!, // Border color
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
