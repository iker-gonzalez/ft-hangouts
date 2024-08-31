import 'package:flutter/material.dart';
import 'screens/contact_list_page.dart';
import 'package:ft_hangouts/database/database.dart';
import 'package:ft_hangouts/widgets/header_widget.dart';
import 'package:telephony/telephony.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  await DatabaseHelper.instance.database; // Initialize database

  final Telephony telephony = Telephony.instance;

  bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
  if (permissionsGranted != null && permissionsGranted) {
    runApp(const MyApp());
  } else {
    print("SMS permissions not granted");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        appBar: HeaderComponent(),
        body: ContactListPage(),
      ),
    );
  }
}