import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'screens/contact_list_page.dart';
import 'package:ft_hangouts/database/database.dart';
import 'package:ft_hangouts/widgets/header_widget.dart';

// Top-level function to handle background messages
void backgroundMessageHandler(SmsMessage message) async {
  // Handle background message
  DatabaseHelper.instance.insertChatMessage({
    DatabaseHelper.columnMessage: message.body ?? '',
    DatabaseHelper.columnIsSent: 0,
    DatabaseHelper.columnTimestamp: DateTime.now().millisecondsSinceEpoch,
    DatabaseHelper.columnContactId: message.address, // Adjust as needed
  });
}

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
      home: Scaffold(
        appBar: HeaderComponent(),
        body: ContactListPage(),
      ),
    );
  }
}