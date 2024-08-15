import 'package:flutter_test/flutter_test.dart';
import 'package:ft_hangouts/database/database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('DatabaseHelper', () {
    late DatabaseHelper dbHelper;

    setUpAll(() async {
      dbHelper = await DatabaseHelper.privateConstructor('test.db');
    });

    test('addContact adds a contact', () async {
      final contact = {
        DatabaseHelper.columnName: 'Test', 
        DatabaseHelper.columnPhoneNumber: '1234567890',
        DatabaseHelper.columnEmail: 'test@example.com',
        DatabaseHelper.columnAddress: '123 Test Street',
        DatabaseHelper.columnCompany: 'Test Company',
      };

      await dbHelper.insert(contact);

      expect(await dbHelper.queryAllRows(), contains(contact));
    });

    test('deleteContact removes a contact', () async {
      final contact = {
        DatabaseHelper.columnName: 'Test', 
        DatabaseHelper.columnPhoneNumber: '1234567890',
        DatabaseHelper.columnEmail: 'test@example.com',
        DatabaseHelper.columnAddress: '123 Test Street',
        DatabaseHelper.columnCompany: 'Test Company',
      };

      int id = await dbHelper.insert(contact);
      await dbHelper.delete(id);

      expect(await dbHelper.queryAllRows(), isNot(contains(contact)));
    });

    test('updateContact updates a contact', () async {
      final oldContact = {
        DatabaseHelper.columnName: 'Test', 
        DatabaseHelper.columnPhoneNumber: '1234567890',
        DatabaseHelper.columnEmail: 'test@example.com',
        DatabaseHelper.columnAddress: '123 Test Street',
        DatabaseHelper.columnCompany: 'Test Company',
      };
      final newContact = {
        DatabaseHelper.columnName: 'Updated', 
        DatabaseHelper.columnPhoneNumber: '987365413',
        DatabaseHelper.columnEmail: 'updated@example.com',
        DatabaseHelper.columnAddress: '123 Burleigh Street',
        DatabaseHelper.columnCompany: 'Updated Company',
      };

      int id = await dbHelper.insert(oldContact);
      newContact[DatabaseHelper.columnId] = id.toString();
      await dbHelper.update(newContact);

      expect(await dbHelper.queryAllRows(), isNot(contains(oldContact)));
      expect(await dbHelper.queryAllRows(), contains(newContact));
    });

    tearDown(() async {
      await dbHelper.deleteAllRows();
    });
  });
}