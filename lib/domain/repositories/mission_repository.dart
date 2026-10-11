import '../entities/mission.dart';

abstract class MissionRepository {
  Future<void> enregistrerMission(Mission mission);
  Future<Mission?> obtenirMissionParNumero(String numeroTrain);
  Future<void> supprimerMission(String numeroTrain);
}
