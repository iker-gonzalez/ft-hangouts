import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ft_hangouts/database/database.dart';
import 'package:ft_hangouts/screens/contact_list_page.dart';

void main() {
  group('ContactListPage', () {
    late DatabaseHelper dbHelper;

    setUpAll(() async {
      dbHelper = DatabaseHelper.privateConstructor('test.db');
    });

    testWidgets('displays a list of contacts', (tester) async {
      final contact = {
        DatabaseHelper.columnId: 1,
        DatabaseHelper.columnName: 'Test44',
        DatabaseHelper.columnPhoneNumber: '12345678902',
        DatabaseHelper.columnEmail: 'test@example.com',
        DatabaseHelper.columnAddress: '123 Test Street',
        DatabaseHelper.columnCompany: 'Test Company',
      };

      await dbHelper.insert(contact);
      await tester.pumpWidget(
        MaterialApp(home: ContactListPage()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test44'), findsOneWidget);
      expect(find.text('Phone: 12345678902'), findsOneWidget);
      expect(find.text('Email: test@example.com'), findsOneWidget);
      expect(find.text('Address: 123 Test Street'), findsOneWidget);
    });

    tearDown(() async {
      await dbHelper.deleteAllRows();
    });
  });
}