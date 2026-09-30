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
    final model = MissionModel(
      numeroTrain: mission.numeroTrain,
      nomChefDeTrain: mission.nomChefDeTrain,
      heureDepart: mission.heureDepart,
      heureArrivee: mission.heureArrivee,
      anomaliesDepart: mission.anomaliesDepart,
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
  Future<Mission?> getActiveMission() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'missions',
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final String numeroTrainActive = maps.first['numeroTrain'];

    final List<Map<String, dynamic>> anomalyMaps = await db.query(
      'anomalies',
      where: 'numeroTrain = ?',
      whereArgs: [numeroTrainActive],
    );

    List<String> anomalies = anomalyMaps
        .map((ligne) => ligne['description'] as String)
        .toList();

    return MissionModel.fromMap(maps.first, anomalies);
  }
}
