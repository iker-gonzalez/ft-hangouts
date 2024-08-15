import 'package:flutter/material.dart';
import '../database/database.dart';

class ContactEditPage extends StatefulWidget {
  final Map<String, dynamic>? contact;

  const ContactEditPage({super.key, this.contact});

  @override
  ContactEditPageState createState() => ContactEditPageState();
}

class ContactEditPageState extends State<ContactEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _companyController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?[DatabaseHelper.columnName]);
    _phoneNumberController = TextEditingController(text: widget.contact?[DatabaseHelper.columnPhoneNumber]);
    _emailController = TextEditingController(text: widget.contact?[DatabaseHelper.columnEmail]);
    _addressController = TextEditingController(text: widget.contact?[DatabaseHelper.columnAddress]);
    _companyController = TextEditingController(text: widget.contact?[DatabaseHelper.columnCompany]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _companyController,
              decoration: const InputDecoration(labelText: 'Company'),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                final contact = {
                  DatabaseHelper.columnName: _nameController.text,
                  DatabaseHelper.columnPhoneNumber: _phoneNumberController.text,
                  DatabaseHelper.columnEmail: _emailController.text,
                  DatabaseHelper.columnAddress: _addressController.text,
                  DatabaseHelper.columnCompany: _companyController.text,
                };
                if (widget.contact != null) {
                  contact[DatabaseHelper.columnId] = widget.contact![DatabaseHelper.columnId];
                  await DatabaseHelper.instance.update(contact);
                } else {
                  await DatabaseHelper.instance.insert(contact);
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