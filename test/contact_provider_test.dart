import 'package:flutter_test/flutter_test.dart';
import 'package:ft_hangouts/database/database.dart';

void main() {
  group('DatabaseHelper', () {
    late DatabaseHelper dbHelper;

    setUpAll(() async {
      dbHelper = await DatabaseHelper.privateConstructor('test.db');
    });

    test('addContact adds a contact', () async {
      final contact = {
        'name': 'Test', 
        'phoneNumber': '1234567890',
        'email': 'test@example.com',
        'address': '123 Test Street',
        'company': 'Test Company',
      };

      await dbHelper.insert(contact);

      expect(await dbHelper.queryAllRows(), contains(contact));
    });

    test('deleteContact removes a contact', () async {
      final contact = {
        'name': 'Test', 
        'phoneNumber': '1234567890',
        'email': 'test@example.com',
        'address': '123 Test Street',
        'company': 'Test Company',
      };

      int id = await dbHelper.insert(contact);
      await dbHelper.delete(id);

      expect(await dbHelper.queryAllRows(), isNot(contains(contact)));
    });

    test('updateContact updates a contact', () async {
      final oldContact = {
        'name': 'Test', 
        'phoneNumber': '1234567890',
        'email': 'test@example.com',
        'address': '123 Test Street',
        'company': 'Test Company',
      };
      final newContact = {
        'name': 'Updated', 
        'phoneNumber': '987365413',
        'email': 'updated@example.com',
        'address': '123 Burleigh Street',
        'company': 'Updated Company',
      };

      int id = await dbHelper.insert(oldContact);
      newContact['_id'] = id.toString();
      await dbHelper.update(newContact);

      expect(await dbHelper.queryAllRows(), isNot(contains(oldContact)));
      expect(await dbHelper.queryAllRows(), contains(newContact));
    });

    tearDown(() async {
      await dbHelper.deleteAllRows();
    });
  });
}