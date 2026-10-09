import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'exploitation_ferroviaire.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE missions (
            numeroTrain TEXT PRIMARY KEY,
            date TEXT,
            heureDepart TEXT,
            heureArrivee TEXT,
            gareDepart TEXT,
            gareArrivee TEXT,
            nomChefDeTrain TEXT,
            numeroChefDeTrain TEXT,
            billetsControles INTEGER,
            voyageursPremiereCl INTEGER, -- Alignée en français !
            voyageursSecondeCl INTEGER,   -- Alignée en français !
            comptageRabat INTEGER,
            comptageTerminal INTEGER,
            typeService TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE anomalies (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            numeroTrain TEXT,
            description TEXT,
            FOREIGN KEY (numeroTrain) REFERENCES missions (numeroTrain) ON DELETE CASCADE
          )
        ''');
      },
    );
  }
}
