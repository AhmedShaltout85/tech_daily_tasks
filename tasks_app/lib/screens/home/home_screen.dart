import 'package:flutter/material.dart';
import 'package:tasks_app/utils/app_colors.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.blackColor),
            onPressed: () {
              //logout from firebase
              // FirebaseApiSAuthServices.signOut();
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Add your widgets here
          Center(
            child: Text(
              'Home Screen Body',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: MaterialButton(
              color: AppColors.primaryColor,
              textColor: AppColors.whiteColor,
              child: Text('Verify Email'),
              onPressed: () {
                //logout from firebase
                // FirebaseApiSAuthServices.verifyEmail();
              },
            ),
          ),
        ],
      ),
    );
  }
}
