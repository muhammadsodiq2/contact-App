import 'package:contact_app/src/madel/contact_madel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  /// instance → bu bitta obyekt yaratib qo‘yadi (singleton pattern).
  /// _database → SQLite bilan bog‘lanish uchun. Bitta marta ochiladi va keyin shu orqali ishlaydi.
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Agar _database ochilgan bo‘lsa → uni qaytaradi.
  /// Agar yo‘q bo‘lsa → _initDB() orqali ochadi.
  /// Demak, faqat birinchi chaqirilganda DB fayl yaratiladi/ochiladi.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("contacts.db");
    return _database!;
  }

  /// getDatabasesPath() → telefon ichida SQLite fayllari saqlanadigan joyni oladi.
  /// join(dbPath, filePath) → contacts.db faylini shu joyga qo‘shib beradi.
  /// openDatabase() → DB ni ochadi yoki bo‘lmasa yaratadi.
  /// Agar yangidan yaratilsa → onCreate chaqiriladi.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  /// contacts nomli jadval yaratiladi.
  /// Uchinchi ustunlar bor:
  /// id → PRIMARY KEY, har safar yangi contact qo‘shilganda avtomatik +1 bo‘ladi.
  /// name → majburiy (NOT NULL).
  /// phone → majburiy (NOT NULL).
  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE contacts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT NOT NULL
    )
    ''');
  }

  ///contact.toMap() → obyektni Map<String, dynamic> ga aylantiradi.
  ///db.insert() → contacts jadvaliga qo‘shadi.
  /// Qaytaradigan qiymat → qo‘shilgan contactning id raqami.
  Future<int> create(ContactMadel contact) async {
    final db = await instance.database;
    return await db.insert('contacts', contact.toMap());
  }

  /// db.query('contacts') → barcha contactlarni oladi.
  /// orderBy: "id DESC" → eng oxirgi qo‘shilgan contact birinchi chiqadi.
  /// result.map(...).toList() → har bir Mapni ContactMadel obyektiga o‘giradi.
  Future<List<ContactMadel>> readAllContacts() async {
    final db = await instance.database;
    final result = await db.query('contacts', orderBy: "id DESC");
    return result.map((json) => ContactMadel.fromMap(json)).toList();
  }

  /// db.update() → mavjud contactni yangilaydi.
  /// where: 'id = ?' → qaysi contactni yangilash kerakligini ko‘rsatadi.
  /// whereArgs: [contact.id] → ? o‘rniga id qo‘yiladi.
  /// Qaytadigan qiymat → nechta qator yangilangani.
  Future<int> update(ContactMadel contact) async {
    final db = await instance.database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  /// db.delete() → jadvaldan id bo‘yicha o‘chiradi.
  /// Qaytadigan qiymat → nechta qator o‘chirilgani.
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }
}
