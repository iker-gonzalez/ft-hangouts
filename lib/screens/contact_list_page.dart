import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:ft_hangouts/database/database.dart';
import 'contact_edit_page.dart';
import 'chat_page.dart';
import 'package:ft_hangouts/generated/l10n.dart';

class ContactListPage extends StatefulWidget {
  final ValueNotifier<Locale> localeNotifier;

  const ContactListPage({super.key, required this.localeNotifier});

  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  late Future<List<Map<String, dynamic>>> _contactListFuture;
  final Telephony telephony = Telephony.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _contactListFuture = _dbHelper.queryAllRows();
    _dbHelper.contactUpdateStream.listen((_) {
      setState(() {
        _contactListFuture = _dbHelper.queryAllRows();
      });
    });
  }

  void _makeCall(String phoneNumber) async {
    bool? permissionsGranted = await telephony.requestPhonePermissions;
    if (permissionsGranted != null && permissionsGranted) {
      try {
        await telephony.dialPhoneNumber(phoneNumber);
      } catch (e) {
        print("Failed to make call: $e");
      }
    } else {
      print("Phone call permissions not granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _contactListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final contacts = snapshot.data ?? [];
            return ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  title: Text(contact[DatabaseHelper.columnName]),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${localizations.phone}: ${contact[DatabaseHelper.columnPhoneNumber]}'),
                      Text('${localizations.email}: ${contact[DatabaseHelper.columnEmail]}'),
                      Text('${localizations.address}: ${contact[DatabaseHelper.columnAddress]}'),
                      Text('${localizations.company}: ${contact[DatabaseHelper.columnCompany]}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.call),
                        onPressed: () => _makeCall(contact[DatabaseHelper.columnPhoneNumber]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                contactName: contact[DatabaseHelper.columnName],
                                contactPhoneNumber: contact[DatabaseHelper.columnPhoneNumber],
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _dbHelper.delete(contact[DatabaseHelper.columnId]);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactEditPage(contact: contact),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ContactEditPage(),
            ),
          );
        },
      ),
    );
  }
}