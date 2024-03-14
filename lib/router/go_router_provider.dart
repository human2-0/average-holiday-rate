// main.dart or providers.dart
import 'package:average_holiday_rate_pay/router/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Import your AppRouter class

final routerProvider = Provider<GoRouter>((ref) => AppRouter(ref).router);
