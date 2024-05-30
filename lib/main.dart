import 'package:average_holiday_rate_pay/firebase_options.dart';
import 'package:average_holiday_rate_pay/models/payslip_model.dart';
import 'package:average_holiday_rate_pay/models/settings_model.dart';
import 'package:average_holiday_rate_pay/router/go_router_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  PaintingBinding.shaderWarmUp = MyShaderWarmUp();

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


    return MaterialApp.router(
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

class MyShaderWarmUp extends ShaderWarmUp {
  @override
  Future<void> warmUpOnCanvas(Canvas canvas) async {
    canvas.drawPaint(
      Paint()
        ..shader = const LinearGradient(
          colors: [Colors.red, Colors.blue],
        ).createShader(const Rect.fromLTWH(0, 0, 400, 400)),
    );
  }
}
