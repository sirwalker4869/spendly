import 'package:flutter/material.dart';
import 'screens/main_navigation_wrapper.dart';
import 'package:intl/date_symbol_data_local.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null); // Inisialisasi format Indonesia
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          primary: const Color(0xFF10B981),
        ),
      ),
      home: const MainNavigationWrapper(),
    );
  }
}