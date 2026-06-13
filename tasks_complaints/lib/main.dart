import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'controller/complaint_provider.dart';
import 'controller/lookup_provider.dart';
import 'controller/chatbot_provider.dart';
import 'services/connectivity_service.dart';
import 'utils/app_theme.dart';
import 'utils/app_route.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/add_complaint/add_complaint_screen.dart';
import 'screens/chatbot/chatbot_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar_SA', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => LookupProvider()),
        ChangeNotifierProvider(create: (_) => ChatbotProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ConnectivityService _connectivityService = ConnectivityService. instance;

  @override
  void initState() {
    super.initState();
    _listenToConnectivityChanges();
  }

  void _listenToConnectivityChanges() {
    _connectivityService.onConnectivityChanged.listen((connected) {
      if (mounted && !connected) {
        _showNoInternetSnackBar();
      }
    });
  }

  void _showNoInternetSnackBar() {
    if (!mounted) return;
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(
        content: Center(
          child: Text('لا يوجد اتصال بالإنترنت'),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'شكاوى الموظفين',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      initialRoute: AppRoute.splashRoute,
      routes: {
        AppRoute.splashRoute: (_) => const SplashScreen(),
        AppRoute.homeRoute: (_) => const HomeScreen(),
        AppRoute.addComplaintRoute: (_) => const AddComplaintScreen(),
        AppRoute.chatbotRoute: (_) => const ChatbotScreen(),
      },
    );
  }
}
