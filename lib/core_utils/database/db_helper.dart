import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  // 👥 Pattern Singleton pour garantir une instance unique de la base de données
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  Database? _database;

  // 🚪 Point d'accès asynchrone à la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // 🛠️ Initialisation et ouverture du fichier de base de données
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'exploitation_ferroviaire.db');

    return await openDatabase(
      path,
      version: 1,
      // 🔥 CRUCIAL POUR SQLITE : Active le support des clés étrangères et du ON DELETE CASCADE
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // 1️⃣ Table principale : Stockage des informations de la mission
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
            voyageursPremiereCl INTEGER,
            voyageursSecondeCl INTEGER,
            comptageRabat INTEGER,
            comptageTerminal INTEGER,
            typeService TEXT
          )
        ''');

        // 2️⃣ Table secondaire : Stockage des anomalies associées
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
