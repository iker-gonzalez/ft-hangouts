import '../database/database.dart';

class Contact {
  int id;
  String name;
  String phoneNumber;
  String email;
  String address;
  String company;

  Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.company,
  });

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map[DatabaseHelper.columnId],
      name: map[DatabaseHelper.columnName],
      phoneNumber: map[DatabaseHelper.columnPhoneNumber],
      email: map[DatabaseHelper.columnEmail],
      address: map[DatabaseHelper.columnAddress],
      company: map[DatabaseHelper.columnCompany],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnPhoneNumber: phoneNumber,
      DatabaseHelper.columnEmail: email,
      DatabaseHelper.columnAddress: address,
      DatabaseHelper.columnCompany: company,
    };
  }
}