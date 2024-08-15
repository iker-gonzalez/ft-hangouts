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
        DatabaseHelper.columnName: 'Test1', 
        DatabaseHelper.columnPhoneNumber: '1234567890',
        DatabaseHelper.columnEmail: 'test1@example.com',
        DatabaseHelper.columnAddress: '123 Test Street',
        DatabaseHelper.columnCompany: 'Test1 Company',
      };

      await dbHelper.insert(contact);

      expect(await dbHelper.queryAllRows(), contains(contact));
    });

    test('deleteContact removes a contact', () async {
      final contact = {
        DatabaseHelper.columnName: 'Test2', 
        DatabaseHelper.columnPhoneNumber: '1234567890',
        DatabaseHelper.columnEmail: 'test2@example.com',
        DatabaseHelper.columnAddress: '123 Test Street',
        DatabaseHelper.columnCompany: 'Test2 Company',
      };

      int id = await dbHelper.insert(contact);
      await dbHelper.delete(id);

      expect(await dbHelper.queryAllRows(), isNot(contains(contact)));
    });

    test('updateContact updates a contact', () async {
      final oldContact = {
        DatabaseHelper.columnName: 'Test3', 
        DatabaseHelper.columnPhoneNumber: '1234567890',
        DatabaseHelper.columnEmail: 'test3@example.com',
        DatabaseHelper.columnAddress: '123 Test Street',
        DatabaseHelper.columnCompany: 'Test Company',
      };
      final newContact = {
        DatabaseHelper.columnName: 'Test4 updated', 
        DatabaseHelper.columnPhoneNumber: '987365413',
        DatabaseHelper.columnEmail: 'test4updated@example.com',
        DatabaseHelper.columnAddress: '123 Burleigh Street',
        DatabaseHelper.columnCompany: 'Test4 Updated Company',
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