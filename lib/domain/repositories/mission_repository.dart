import '../entities/mission.dart';

abstract class MissionRepository {
  Future<void> saveMission(Mission mission);
  Future<Mission?> getActiveMission();
}
