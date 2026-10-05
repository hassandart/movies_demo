import '../entities/mission.dart';

abstract class MissionRepository {
  // Enregistrement ou modification d'une ligne de train
  Future<void> saveMission(Mission mission);

  // Récupération de la dernière mission active au démarrage
  Future<Mission?> getActiveMission();

  // ALIMENTE LA LISTE VERTICALE : Récupère l'historique complet depuis sqflite
  Future<List<Mission>> getAllMissions();

  // BOUTON SUPPRIMER : Efface définitivement le train de la base locale
  Future<void> deleteMission(String numeroTrain);
}
