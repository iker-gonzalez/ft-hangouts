import 'package:flutter/foundation.dart';
import '../models/contact.dart';

class ContactProvider with ChangeNotifier {
  List<Contact> _contacts = [];

  List<Contact> get contacts => _contacts;

  void addContact(Contact contact) {
    _contacts.add(contact);
    notifyListeners();
  }

  void deleteContact(Contact contact) {
    _contacts.remove(contact);
    notifyListeners();
  }

  void updateContact(Contact oldContact, Contact newContact) {
    final index = _contacts.indexOf(oldContact);
    if (index != -1) {
      _contacts[index] = newContact;
      notifyListeners();
    }
  }
}