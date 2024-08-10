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
      provider.addContact(Contact(name: 'Test', phoneNumber: '1234567890'));

      await tester.pumpWidget(
        ChangeNotifierProvider<ContactProvider>.value(
          value: provider,
          child: MaterialApp(home: ContactListPage()),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.text('1234567890'), findsOneWidget);
    });
  });
}