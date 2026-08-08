import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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