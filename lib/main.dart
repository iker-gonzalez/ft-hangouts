import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'screens/contact_list_page.dart';
import 'package:ft_hangouts/database/database.dart';
import 'package:ft_hangouts/widgets/header_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ft_hangouts/generated/l10n.dart';

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
  runApp(const MyApp()); // Ensure MyApp is not instantiated as const
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en', 'US'));
  DateTime? _backgroundTime;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  bool _snackBarShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now();
      _snackBarShown = false;
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTime != null && !_snackBarShown) {
        final timeInBackground = DateTime.now().difference(_backgroundTime!);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text('App was in background for ${timeInBackground.inSeconds} seconds')),
          );
          _snackBarShown = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          scaffoldMessengerKey: _scaffoldMessengerKey,
          home: Scaffold(
            appBar: HeaderComponent(localeNotifier: localeNotifier),
            body: ContactListPage(localeNotifier: localeNotifier),
          ),
        );
      },
    );
  }
}