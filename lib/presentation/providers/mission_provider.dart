import 'package:flutter/material.dart';
import 'package:movies_demo/domain/repositories/mission_repository.dart';
import 'package:movies_demo/domain/entities/mission.dart';

class MissionProvider extends ChangeNotifier {
  final MissionRepository repository;

  Mission? _missionActuelle;
  List<Mission> _listeMissions = [];
  bool _isLoading = false;

  MissionProvider({required this.repository}) {
    chargerToutesLesMissions();
  }

  Mission? get missionActuelle => _missionActuelle;
  List<Mission> get listeMissions => _listeMissions;
  bool get isLoading => _isLoading;

  void reinitialiserSaisie() {
    _missionActuelle = null;
    notifyListeners();
  }

  void selectionnerMissionPourModification(Mission mission) {
    _missionActuelle = mission;
    notifyListeners();
  }

  Future<void> chargerToutesLesMissions() async {
    _isLoading = true;
    notifyListeners();
    try {
      _listeMissions = await repository.getAllMissions();
    } catch (e) {
      debugPrint(
        "Erreur lors du chargement des missions dans le Provider : $e",
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> enregistrerMission(Mission mission) async {
    _isLoading = true;
    notifyListeners();
    try {
      await repository.saveMission(mission);
      _listeMissions = await repository.getAllMissions();
    } catch (e) {
      debugPrint("Erreur lors de l'enregistrement dans le Provider : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> supprimerMission(String numeroTrain) async {
    _isLoading = true;
    notifyListeners();
    try {
      await repository.deleteMission(numeroTrain);
      _listeMissions = await repository.getAllMissions();
      if (_missionActuelle?.numeroTrain == numeroTrain) {
        _missionActuelle = null;
      }
    } catch (e) {
      debugPrint("Erreur lors de la suppression dans le Provider : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
