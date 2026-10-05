import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'mission_train.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE missions(
            numeroTrain TEXT PRIMARY KEY,
            date TEXT,
            heureDepart TEXT,
            heureArrivee TEXT,
            gareDepart TEXT,
            gareArrivee TEXT,
            nomChefDeTrain TEXT,
            numeroChefDeTrain TEXT,
            nombreVoitures INTEGER,
            voyagersPremiereCl INTEGER,
            voyagersSecondeCl INTEGER,
            billetsControles INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE anomalies(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            numeroTrain TEXT,
            description TEXT
          )
        ''');
      },
    );
  }
}
