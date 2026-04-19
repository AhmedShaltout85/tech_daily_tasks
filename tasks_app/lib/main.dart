import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tasks_app/controller/local_control/cache_helper.dart';
import 'package:tasks_app/controller/theme_provider.dart';
import 'package:tasks_app/screens/login/login_screen.dart';
import 'package:tasks_app/screens/signup/signup_screen.dart';
import 'package:tasks_app/screens/splash/splash_screen.dart';

import 'package:tasks_app/utils/app_route.dart';
import 'package:tasks_app/utils/app_theme.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Initialize Shared Preferences
  await CacheHelper.init();

  runApp(
    MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => TaskProviders()),
        // ChangeNotifierProvider(create: (_) => AppNameProvider()),
        // ChangeNotifierProvider(create: (_) => EmployeeNameProvider()),
        // ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Tasks App',
          theme: themeProvider.themeMode == ThemeMode.dark
              ? AppTheme.darkTheme
              : AppTheme.lightTheme,
          initialRoute: AppRoute.splashRouteName,
          routes: {
            AppRoute.splashRouteName: (context) => const SplashScreen(),
            AppRoute.loginRouteName: (context) => const LoginScreen(),
            AppRoute.signupRouteName: (context) => const SignUpScreen(),
            // AppRoute.taskRouteName: (context) => const TaskScreen(),
            // AppRoute.userTaskRouteName: (context) => UserTaskScreen(),
            // AppRoute.authWrapperRouteName: (context) => const AuthWrapper(),
          },
        );
      },
    );
  }
}
