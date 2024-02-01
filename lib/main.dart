import 'package:average_holiday_rate_pay/customs/toast.dart';
import 'package:average_holiday_rate_pay/firebase_options.dart';
import 'package:average_holiday_rate_pay/models/payslip.dart';
import 'package:average_holiday_rate_pay/models/settings.dart';
import 'package:average_holiday_rate_pay/router/go_router_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  await Hive.initFlutter();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Hive
    ..registerAdapter(PayslipAdapter())
    ..registerAdapter(SettingsAdapter());
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp> {

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    Future.microtask(() async => Hive.close());
    super.dispose();
  }



  // This widget is the root of your application.
  @override
  Widget build(
    BuildContext context,
  ) {
    final router = ref.watch(routerProvider);
    CustomToast.initialize(context);


    return MaterialApp.router(
      builder: FToastBuilder(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue[800]!),
        useMaterial3: true,
      ),
    );
  }
}
