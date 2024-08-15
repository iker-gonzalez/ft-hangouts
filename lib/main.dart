import 'package:flutter/material.dart';
import 'screens/contact_list_page.dart';
import 'package:ft_hangouts/database/database.dart'; // Import your DatabaseHelper class

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  await DatabaseHelper.instance.database; // Initialize database

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ContactListPage(),
    );
  }
}