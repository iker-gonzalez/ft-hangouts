import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../providers/contact_provider.dart';

class ContactEditPage extends StatefulWidget {
  final Contact? contact;

  ContactEditPage({this.contact});

  @override
  _ContactEditPageState createState() => _ContactEditPageState();
}

class _ContactEditPageState extends State<ContactEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name);
    _phoneNumberController =
        TextEditingController(text: widget.contact?.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                final contactProvider =
                    Provider.of<ContactProvider>(context, listen: false);
                final contact = Contact(
                  name: _nameController.text,
                  phoneNumber: _phoneNumberController.text,
                );
                if (widget.contact != null) {
                  contactProvider.updateContact(widget.contact!, contact);
                } else {
                  contactProvider.addContact(contact);
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}