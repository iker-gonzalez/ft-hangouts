import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 2; // Incremented version

  static const tableContacts = 'contacts';
  static const tableChatMessages = 'chat_messages';

  static const columnId = '_id';
  static const columnName = 'name';
  static const columnPhoneNumber = 'phone_number';
  static const columnEmail = 'email';
  static const columnAddress = 'address';
  static const columnCompany = 'company';
  static const columnImagePath = 'image_path';

  static const columnContactId = 'contact_id';
  static const columnMessage = 'message';
  static const columnIsSent = 'is_sent';
  static const columnTimestamp = 'timestamp';

  // Singleton instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static Database? _database;
  final _contactStreamController = StreamController<void>.broadcast();
  final _chatMessageStreamController = StreamController<void>.broadcast();

  Stream<void> get contactUpdateStream => _contactStreamController.stream;
  Stream<void> get chatMessageUpdateStream => _chatMessageStreamController.stream;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<String> get _databasePath async {
    return await getDatabasesPath();
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Example schema change: Add a new column to chat_messages table
      await db.execute('ALTER TABLE $tableChatMessages ADD COLUMN new_column_name TEXT');
    }
  }

  Future _initDatabase() async {
    return await openDatabase(
      join(await _databasePath, _databaseName),
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

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
        $columnContactId TEXT NOT NULL,
        $columnMessage TEXT NOT NULL,
        $columnIsSent INTEGER NOT NULL,
        $columnTimestamp INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = await db.insert(tableContacts, row);
    _contactStreamController.add(null); // Notify listeners of the update
    return id;
  }

  Future<int> insertChatMessage(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = await db.insert(tableChatMessages, row);
    _chatMessageStreamController.add(null); // Notify listeners of the new message
    return id;
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(tableContacts);
  }

  Future<int> queryRowCount() async {
    Database db = await instance.database;
    int? rowCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableContacts'));
    return rowCount ?? 0;
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = int.parse(row[columnId]);
    int result = await db.update(tableContacts, row, where: '$columnId = ?', whereArgs: [id]);
    _contactStreamController.add(null); // Notify listeners of the update
    return result;
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    int result = await db.delete(tableContacts, where: '$columnId = ?', whereArgs: [id]);
    _contactStreamController.add(null); // Notify listeners of the update
    return result;
  }

  Future<int> deleteAllRows() async {
    Database db = await instance.database;
    int result = await db.delete(tableContacts);
    _contactStreamController.add(null); // Notify listeners of the update
    return result;
  }

  Future<List<Map<String, dynamic>>> queryAllChatMessages() async {
    Database db = await instance.database;
    return await db.query(tableChatMessages);
  }

  Stream<List<Map<String, dynamic>>> getMessagesStream(String contactPhoneNumber) async* {
    yield await queryChatMessagesByContactId(contactPhoneNumber);
  }

  Future<List<Map<String, dynamic>>> queryChatMessagesByContactId(String contactPhoneNumber) async {
    Database db = await instance.database;
    return await db.query(
        tableChatMessages,
        where: '$columnContactId = ?',
        whereArgs: [contactPhoneNumber],
        orderBy: '$columnTimestamp ASC'
    );
  }

  Future<List<Map<String, dynamic>>> queryContactByPhoneNumber(String phoneNumber) async {
    Database db = await instance.database;
    return await db.query(
      tableContacts, // Corrected table name
      where: '$columnPhoneNumber = ?',
      whereArgs: [phoneNumber],
    );
  }

  void dispose() {
    _contactStreamController.close();
    _chatMessageStreamController.close();
  }
}