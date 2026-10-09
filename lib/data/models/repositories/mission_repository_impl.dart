import 'package:movies_demo/data/models/mission_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core_utils/database/db_helper.dart';
import '../../../domain/entities/mission.dart';
import '../../../domain/repositories/mission_repository.dart';

class MissionRepositoryImpl implements MissionRepository {
  final DbHelper dbHelper = DbHelper();

  @override
  Future<void> saveMission(Mission mission) async {
    final db = await dbHelper.database;

    // 🛡️ ALIGNEMENT DE TOUTES LES PROPRIÉTÉS EN FRANÇAIS : voyageursPremiereCl et voyageursSecondeCl
    final model = MissionModel(
      numeroTrain: mission.numeroTrain,
      date: mission.date,
      heureDepart: mission.heureDepart,
      heureArrivee: mission.heureArrivee,
      gareDepart: mission.gareDepart,
      gareArrivee: mission.gareArrivee,
      nomChefDeTrain: mission.nomChefDeTrain,
      numeroChefDeTrain: mission.numeroChefDeTrain,
      anomaliesDepart: mission.anomaliesDepart,
      billetsControles: mission.billetsControles,
      voyageursPremiereCl: mission.voyageursPremiereCl,
      voyageursSecondeCl: mission.voyageursSecondeCl,
      comptageRabat: mission.comptageRabat,
      comptageTerminal: mission.comptageTerminal,
      typeService: mission.typeService,
    );

    await db.transaction((txn) async {
      await txn.insert(
        'missions',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.delete(
        'anomalies',
        where: 'numeroTrain = ?',
        whereArgs: [model.numeroTrain],
      );
      for (var anomalie in model.anomaliesDepart) {
        await txn.insert('anomalies', {
          'numeroTrain': model.numeroTrain,
          'description': anomalie,
        });
      }
    });
  }

  @override
  Future<List<Mission>> getAllMissions() async {
    final db = await dbHelper.database;

    // 🛡️ OPTIMISATION DU TRI : Tri par ID de ligne décroissant pour voir le dernier train saisi en premier
    final List<Map<String, dynamic>> maps = await db.query(
      'missions',
      orderBy: 'rowid DESC',
    );

    List<Mission> liste = [];
    for (var map in maps) {
      // 🛡️ ISOLATION EXPLICITE DE L'INDEX : Garantit que chaque clic charge le bon train sans écrasement
      final String numTrainSpecifique = map['numeroTrain'].toString();

      final List<Map<String, dynamic>> anomalyMaps = await db.query(
        'anomalies',
        where: 'numeroTrain = ?',
        whereArgs: [numTrainSpecifique],
      );

      List<String> anomalies = anomalyMaps
          .map((l) => l['description'] as String)
          .toList();

      liste.add(MissionModel.fromMap(map, anomalies));
    }
    return liste;
  }

  @override
  Future<void> deleteMission(String numeroTrain) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'anomalies',
        where: 'numeroTrain = ?',
        whereArgs: [numeroTrain],
      );
      await txn.delete(
        'missions',
        where: 'numeroTrain = ?',
        whereArgs: [numeroTrain],
      );
    });
  }
}
