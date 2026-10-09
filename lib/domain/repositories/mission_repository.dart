import '../entities/mission.dart';

abstract class MissionRepository {
  Future<void> saveMission(Mission mission);
  Future<List<Mission>> getAllMissions();
  Future<void> deleteMission(String numeroTrain);
}
