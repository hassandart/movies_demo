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
        // Table pour les infos principales du train
        await db.execute('''
          CREATE TABLE missions(
            numeroTrain TEXT PRIMARY KEY,
            nomChefDeTrain TEXT,
            heureDepart TEXT,
            heureArrivee TEXT
          )
        ''');
        // Table pour les anomalies (liée au numéro de train)
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
