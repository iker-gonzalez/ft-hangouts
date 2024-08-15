import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../providers/contact_provider.dart';

class ContactEditPage extends StatefulWidget {
  final Contact? contact;

  const ContactEditPage({super.key, this.contact});

  @override
  _ContactEditPageState createState() => _ContactEditPageState();
}

class _ContactEditPageState extends State<ContactEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _companyController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name);
    _phoneNumberController =
        TextEditingController(text: widget.contact?.phoneNumber);
    _emailController = TextEditingController(text: widget.contact?.email);
    _addressController = TextEditingController(text: widget.contact?.address);
    _companyController = TextEditingController(text: widget.contact?.company);
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
              onPressed: () {
                final contactProvider =
                    Provider.of<ContactProvider>(context, listen: false);
                final contact = Contact(
                  name: _nameController.text,
                  phoneNumber: _phoneNumberController.text,
                  email: _emailController.text,
                  address: _addressController.text,
                  company: _companyController.text,
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