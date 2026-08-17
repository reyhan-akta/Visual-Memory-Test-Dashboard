import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/firebase_api_constant.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: FirebaseApiConstants.apiKey,
      authDomain: FirebaseApiConstants.authDomain,
      projectId: FirebaseApiConstants.projectId,
      storageBucket: FirebaseApiConstants.storageBucket,
      messagingSenderId: FirebaseApiConstants.messagingSenderId,
      appId: FirebaseApiConstants.appId,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nimbus Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.mainBackground,
        colorScheme: const ColorScheme.dark(
          background: AppColors.mainBackground,
          surface: AppColors.cardBackground,
          primary: AppColors.primaryAccent,
          secondary: AppColors.secondaryAccent,
        ),
        useMaterial3: true,
      ),
      home: DashboardPage(),
    );
  }
}