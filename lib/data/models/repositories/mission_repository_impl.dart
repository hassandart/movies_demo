import 'package:movies_demo/core_utils/database/db_helper.dart';
import 'package:movies_demo/data/models/mission_model.dart';
import 'package:movies_demo/domain/entities/mission.dart';
// 🔥 ON IMPORTE L'INTERFACE POUR POUVOIR L'IMPLÉMENTER
import 'package:movies_demo/domain/repositories/mission_repository.dart';
import 'package:sqflite/sqflite.dart';

// 🟩 CORRECTION : On utilise "implements MissionRepository" pour lier les deux fichiers
class MissionRepositoryImpl implements MissionRepository {
  final DbHelper _dbHelper = DbHelper();

  @override
  Future<void> enregistrerMission(Mission mission) async {
    final db = await _dbHelper.database;

    final missionModel = MissionModel(
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
        missionModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.delete(
        'anomalies',
        where: 'numeroTrain = ?',
        whereArgs: [missionModel.numeroTrain],
      );

      for (final anomalie in missionModel.anomaliesDepart) {
        if (anomalie.trim().isNotEmpty) {
          await txn.insert('anomalies', {
            'numeroTrain': missionModel.numeroTrain,
            'description': anomalie.trim(),
          });
        }
      }
    });
  }

  @override
  Future<MissionModel?> obtenirMissionParNumero(String numeroTrain) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> mapsMissions = await db.query(
      'missions',
      where: 'numeroTrain = ?',
      whereArgs: [numeroTrain],
    );

    if (mapsMissions.isEmpty) return null;

    final List<Map<String, dynamic>> mapsAnomalies = await db.query(
      'anomalies',
      where: 'numeroTrain = ?',
      whereArgs: [numeroTrain],
    );

    final List<String> listeAnomalies = mapsAnomalies
        .map((row) => row['description'] as String)
        .toList();

    return MissionModel.fromMap(mapsMissions.first, listeAnomalies);
  }

  @override
  Future<void> supprimerMission(String numeroTrain) async {
    final db = await _dbHelper.database;
    await db.delete(
      'missions',
      where: 'numeroTrain = ?',
      whereArgs: [numeroTrain],
    );
  }
}
