import 'package:flutter/material.dart';
import '../database/database.dart';
import 'contact_edit_page.dart';
import 'chat_page.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  late Future<List<Map<String, dynamic>>> _contactListFuture;

  @override
  void initState() {
    super.initState();
    _contactListFuture = DatabaseHelper.instance.queryAllRows();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
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
                      Text('Phone: ${contact[DatabaseHelper.columnPhoneNumber]}'),
                      Text('Email: ${contact[DatabaseHelper.columnEmail]}'),
                      Text('Address: ${contact[DatabaseHelper.columnAddress]}'),
                      Text('Company: ${contact[DatabaseHelper.columnCompany]}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chat),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(contactId: contact[DatabaseHelper.columnId]),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await DatabaseHelper.instance.delete(contact[DatabaseHelper.columnId]);
                          setState(() {
                            _contactListFuture = DatabaseHelper.instance.queryAllRows();
                          });
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
                    ).then((_) {
                      setState(() {
                        _contactListFuture = DatabaseHelper.instance.queryAllRows();
                      });
                    });
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
          ).then((_) {
            setState(() {
              _contactListFuture = DatabaseHelper.instance.queryAllRows();
            });
          });
        },
      ),
    );
  }
}