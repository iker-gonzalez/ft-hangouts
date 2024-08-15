import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ft_hangouts/models/contact.dart';
import 'package:ft_hangouts/providers/contact_provider.dart';
import 'package:ft_hangouts/screens/contact_list_page.dart';

void main() {
  group('ContactListPage', () {
    testWidgets('displays a list of contacts', (tester) async {
      final provider = ContactProvider();
      final contact = Contact(
        name: 'Test44', 
        phoneNumber: '12345678902',
        email: 'test@example.com',
        address: '123 Test Street',
        company: 'Test Company',
      );

      provider.addContact(contact);
      await tester.pumpWidget(
        ChangeNotifierProvider<ContactProvider>.value(
          value: provider,
          child: const MaterialApp(home: ContactListPage()),
        ),
      );

      expect(find.text('Test44'), findsOneWidget);
      expect(find.text('Phone: 12345678902'), findsOneWidget);
      expect(find.text('Email: test@example.com'), findsOneWidget);
      expect(find.text('Address: 123 Test Street'), findsOneWidget);
    });
  });
}