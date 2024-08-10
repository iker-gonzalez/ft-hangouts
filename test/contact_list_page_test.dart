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
        name: 'Test', 
        phoneNumber: '1234567890',
        email: 'test@example.com',
        address: '123 Test Street',
        birthday: DateTime.now(),
        company: 'Test Company',
      );

      provider.addContact(contact);
      await tester.pumpWidget(
        ChangeNotifierProvider<ContactProvider>.value(
          value: provider,
          child: MaterialApp(home: ContactListPage()),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.text('1234567890'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('123 Test Street'), findsOneWidget);
      expect(find.text('Test Company'), findsOneWidget);
    });
  });
}