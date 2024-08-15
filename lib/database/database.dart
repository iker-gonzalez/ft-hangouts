import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseVersion = 1;

  static const table = 'contacts';

  static const columnId = '_id';
  static const columnName = 'name';
  static const columnPhoneNumber = 'phoneNumber';
  static const columnEmail = 'email';
  static const columnAddress = 'address';
  static const columnCompany = 'company';

  // make this a singleton class
  DatabaseHelper.privateConstructor(this._databasePath);
  static final DatabaseHelper instance = DatabaseHelper.privateConstructor("MyDatabase.db");

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  final String _databasePath;

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databasePath);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnPhoneNumber TEXT NOT NULL,
            $columnEmail TEXT NOT NULL,
            $columnAddress TEXT NOT NULL,
            $columnCompany TEXT NOT NULL
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // All of the rows are returned as a list of maps, where each map is 
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    int? rowCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
    return rowCount ?? 0;
  }

  // We are assuming here that the id column in the map is set. The other 
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = int.parse(row[columnId]);
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is 
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes all rows in the table. Only intended for use in tests.
  Future<int> deleteAllRows() async {
    Database db = await instance.database;
    return await db.delete(table);
  }
}