// ignore_for_file: must_be_immutable

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youhow/services/auth_service.dart';
import 'package:youhow/services/call_service.dart';
import 'package:youhow/services/navigation_service.dart';
import 'package:youhow/services/notification_service.dart';
import 'package:youhow/utils.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await setup();
  await NotificationService().initNotifications();
  runApp(MyApp());
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );
  await registerServices();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GetIt getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();

    _navigationService = getIt.get<NavigationService>();
    _authService = getIt.get<AuthService>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Youhow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          secondary: Colors.white,
          primary: Colors.black87,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      navigatorKey: _navigationService.navigatorKey,
      routes: _navigationService.routes,
      debugShowCheckedModeBanner: false,
      initialRoute: _authService.user != null ? '/home' : '/login',
    );
  }
}
