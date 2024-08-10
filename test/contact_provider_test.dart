import 'package:flutter_test/flutter_test.dart';
import 'package:ft_hangouts/providers/contact_provider.dart';
import 'package:ft_hangouts/models/contact.dart';

void main() {
  group('ContactProvider', () {
    test('addContact adds a contact', () {
      final provider = ContactProvider();
      final contact = Contact(
        name: 'Test', 
        phoneNumber: '1234567890',
        email: 'test@example.com',
        address: '123 Test Street',
        company: 'Test Company',
      );

      provider.addContact(contact);

      expect(provider.contacts, contains(contact));
    });

    test('deleteContact removes a contact', () {
      final provider = ContactProvider();
      final contact = Contact(
        name: 'Test', 
        phoneNumber: '1234567890',
        email: 'test@example.com',
        address: '123 Test Street',
        company: 'Test Company',
      );

      provider.addContact(contact);
      provider.deleteContact(contact);

      expect(provider.contacts, isNot(contains(contact)));
    });

    test('updateContact updates a contact', () {
      final provider = ContactProvider();
      final oldContact = Contact(
        name: 'Test', 
        phoneNumber: '1234567890',
        email: 'test@example.com',
        address: '123 Test Street',
        company: 'Test Company',
      );
      final newContact = Contact(
        name: 'Updated', 
        phoneNumber: '987365413',
        email: 'updated@example.com',
        address: '123 Burleigh Street',
        company: 'Updated Company',
      );

      provider.addContact(oldContact);
      provider.updateContact(oldContact, newContact);

      expect(provider.contacts, isNot(contains(oldContact)));
      expect(provider.contacts, contains(newContact));
    });
  });
}