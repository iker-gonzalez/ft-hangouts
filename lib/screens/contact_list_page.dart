import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contact_provider.dart';
import 'contact_edit_page.dart';

class ContactListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: Consumer<ContactProvider>(
        builder: (context, contactProvider, child) {
          return ListView.builder(
            itemCount: contactProvider.contacts.length,
            itemBuilder: (context, index) {
              final contact = contactProvider.contacts[index];
              return ListTile(
                title: Text(contact.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone: ${contact.phoneNumber}'),
                    Text('Email: ${contact.email}'),
                    Text('Address: ${contact.address}'),
                    Text('Birthday: ${contact.birthday.toIso8601String()}'),
                    Text('Company: ${contact.company}'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    contactProvider.deleteContact(contact);
                  },
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
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactEditPage(),
            ),
          );
        },
      ),
    );
  }
}