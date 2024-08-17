import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ContactEditPage extends StatefulWidget {
  final Map<String, dynamic>? contact;

  const ContactEditPage({Key? key, this.contact}) : super(key: key);

  @override
  ContactEditPageState createState() => ContactEditPageState();
}

class ContactEditPageState extends State<ContactEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _companyController;

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(pickedFile.path);
        final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
        setState(() {
          _imageFile = savedImage;
        });
      }
    } catch (e) {
      print('An error occurred while picking the image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?[DatabaseHelper.columnName]);
    _phoneNumberController = TextEditingController(text: widget.contact?[DatabaseHelper.columnPhoneNumber]);
    _emailController = TextEditingController(text: widget.contact?[DatabaseHelper.columnEmail]);
    _addressController = TextEditingController(text: widget.contact?[DatabaseHelper.columnAddress]);
    _companyController = TextEditingController(text: widget.contact?[DatabaseHelper.columnCompany]);

    if (widget.contact != null && widget.contact![DatabaseHelper.columnImagePath] != null) {
      _imageFile = File(widget.contact![DatabaseHelper.columnImagePath]);
    }
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
            if (_imageFile != null) Image.file(_imageFile!),
            TextButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
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
                  'imagePath': _imageFile?.path,
                };
                if (widget.contact != null) {
                  contact[DatabaseHelper.columnId] = widget.contact![DatabaseHelper.columnId].toString();
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