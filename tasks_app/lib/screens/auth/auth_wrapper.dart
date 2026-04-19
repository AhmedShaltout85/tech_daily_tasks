// import 'dart:developer';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:tasks_app/screens/login/login_screen.dart';
// import 'package:tasks_app/screens/task/task_screen.dart';
// import 'package:tasks_app/screens/task/user_task_screen.dart';


// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   bool _isAdminUser(String? email) {
//     if (email == null || email.isEmpty) return false;
//     final username = email.split('@').first.toLowerCase();
//     log('🔍 Checking admin status for username: $username');
//     return username == 'admin';
//   }

//   @override
//   Widget build(BuildContext context) {
//     log('🔄 AuthWrapper build called');

//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         log('📊 StreamBuilder state: ${snapshot.connectionState}');
//         log('📊 Has data: ${snapshot.hasData}');

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           log('⏳ Waiting for auth state...');
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (!snapshot.hasData || snapshot.data == null) {
//           log('❌ No user logged in - showing LoginScreen');
//           return const LoginScreen();
//         }

//         final user = snapshot.data!;
//         log('✅ User logged in: ${user.email}');
//         log('✅ User UID: ${user.uid}');
//         log('✅ User displayName: ${user.displayName}');

//         if (_isAdminUser(user.email)) {
//           log('👑 Admin user detected - showing TaskScreen');
//           return const TaskScreen();
//         } else {
//           log('👤 Regular user detected - showing UserTaskScreen');
//           return const UserTaskScreen();
//         }
//       },
//     );
//   }
// }
