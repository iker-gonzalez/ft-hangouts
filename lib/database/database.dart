import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseVersion = 3;
  static const _databaseName = 'ft_hangouts.db';

  static const tableContacts = 'contacts';

  static const columnId = '_id';
  static const columnName = 'name';
  static const columnPhoneNumber = 'phoneNumber';
  static const columnEmail = 'email';
  static const columnAddress = 'address';
  static const columnCompany = 'company';
  static const columnImagePath = 'imagePath';

  static const tableChatMessages = 'chat_messages';

  static const columnContactId = '_contact_id';
  static const columnMessage = 'message';
  static const columnIsSent = 'is_sent';
  static const columnTimestamp = 'timestamp';

  // make this a singleton class
  DatabaseHelper.privateConstructor(this._databasePath);
  static final DatabaseHelper instance = DatabaseHelper.privateConstructor(_databaseName);

    // Add a StreamController
  final _controller = StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get messagesStream => _controller.stream;

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  final String _databasePath;

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < newVersion) {
    await db.execute('DROP TABLE IF EXISTS $tableContacts');
    await db.execute('DROP TABLE IF EXISTS $tableChatMessages');
    _onCreate(db, newVersion);
  }
}

Future _initDatabase() async {
  return await openDatabase(
    join(_databasePath, _databaseName),
    version: _databaseVersion,
    onCreate: _onCreate,
    onUpgrade: _onUpgrade,
  );
}

  // SQL code to create the database tables
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableContacts (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnPhoneNumber TEXT NOT NULL,
            $columnEmail TEXT NOT NULL,
            $columnAddress TEXT NOT NULL,
            $columnCompany TEXT NOT NULL,
            $columnImagePath TEXT
          )
          ''');

    await db.execute('''
          CREATE TABLE $tableChatMessages (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnContactId INTEGER NOT NULL,
            $columnMessage TEXT NOT NULL,
            $columnIsSent INTEGER NOT NULL,
            $columnTimestamp INTEGER NOT NULL
          )
          ''');
  }

  //* tableContacts Helper methods *//

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableContacts, row);
  }

  // All of the rows are returned as a list of maps, where each map is 
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(tableContacts);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    int? rowCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableContacts'));
    return rowCount ?? 0;
  }

  // We are assuming here that the id column in the map is set. The other 
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = int.parse(row[columnId]);
    return await db.update(tableContacts, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is 
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(tableContacts, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes all rows in the table. Only intended for use in tests.
  Future<int> deleteAllRows() async {
    Database db = await instance.database;
    return await db.delete(tableContacts);
  }

  //* tableChatMessages Helper methods *//



  Future<List<Map<String, dynamic>>> queryAllChatMessages() async {
    Database db = await instance.database;
    return await db.query(tableChatMessages);
  }

  Stream<List<Map<String, dynamic>>> getMessagesStream(int contactId) {
    return Stream.periodic(Duration(seconds: 1)).asyncMap((_) async {
      return await queryChatMessagesByContactId(contactId);
    });
  }

  Future<List<Map<String, dynamic>>> queryChatMessagesByContactId(int contactId) async {
  Database db = await instance.database;
  return await db.query(
    tableChatMessages,
    where: '$columnContactId = ?',
    whereArgs: [contactId],
    orderBy: '$columnTimestamp DESC'
    );
  }

  Future<int> insertChatMessage(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = await db.insert(tableChatMessages, row);

    // Emit a new event with all messages for the contact
    _controller.add(await queryChatMessagesByContactId(row[columnContactId]));

    return id;
  }

  // Add a dispose method to close the StreamController
  void dispose() {
    _controller.close();
  }
}