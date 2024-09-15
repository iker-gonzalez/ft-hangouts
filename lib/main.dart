import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'screens/contact_list_page.dart';
import 'package:ft_hangouts/database/database.dart';
import 'package:ft_hangouts/widgets/header_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ft_hangouts/models/localization.dart';

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
  runApp(MyApp()); // Ensure MyApp is not instantiated as const
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<Locale> _localeNotifier = ValueNotifier(const Locale('en', 'US'));

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: _localeNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          locale: locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('es', 'ES'),
          ],
          home: Scaffold(
            appBar: HeaderComponent(localeNotifier: _localeNotifier),
            body: ContactListPage(localeNotifier: _localeNotifier),
          ),
        );
      },
    );
  }
}