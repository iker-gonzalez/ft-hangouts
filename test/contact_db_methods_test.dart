import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ft_hangouts/database/database.dart';
import 'contact_db_methods_test.mocks.dart';

@GenerateMocks([DatabaseHelper])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('DatabaseHelper', () {
    late MockDatabaseHelper dbHelper;

    setUp(() {
      dbHelper = MockDatabaseHelper();
    });

    test('insert contact', () async {
      final contact = {
        DatabaseHelper.columnName: 'Test Name',
        DatabaseHelper.columnPhoneNumber: '1234567890',
        DatabaseHelper.columnEmail: 'test@email.com',
        DatabaseHelper.columnAddress: 'Test Address',
        DatabaseHelper.columnCompany: 'Test Company',
      };
      when(dbHelper.insert(contact)).thenAnswer((_) async => 1);
      final id = await dbHelper.insert(contact);
      expect(id, 1);
    });

    test('update contact', () async {
      final contact = {
        DatabaseHelper.columnId: 1,
        DatabaseHelper.columnName: 'Updated Name',
        DatabaseHelper.columnPhoneNumber: '0987654321',
        DatabaseHelper.columnEmail: 'updated@email.com',
        DatabaseHelper.columnAddress: 'Updated Address',
        DatabaseHelper.columnCompany: 'Updated Company',
      };
      
      when(dbHelper.update(contact)).thenAnswer((_) async => 1);
      
      final rowsAffected = await dbHelper.update(contact);
      
      expect(rowsAffected, 1);
      verify(dbHelper.update(contact)).called(1);
    });

    test('delete contact', () async {
      // Arrange
      const int contactId = 1;
      when(dbHelper.delete(contactId)).thenAnswer((_) async => 1);

      // Act
      final rowsAffected = await dbHelper.delete(contactId);

      // Assert
      expect(rowsAffected, 1);
      verify(dbHelper.delete(contactId)).called(1);
    });
    
  });
}