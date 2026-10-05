import 'package:flutter/material.dart';

import '../../domain/entities/mission.dart';
import '../../domain/repositories/mission_repository.dart';

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
      final list = await repository.getAllMissions();
      _listeMissions = list;
      if (_listeMissions.isNotEmpty) {
        _missionActuelle = _listeMissions.first;
      } else {
        _missionActuelle = null;
      }
    } catch (e) {
      debugPrint("Erreur chargement missions: $e");
    }
    {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> enregistrerMission(Mission mission) async {
    _isLoading = true;
    notifyListeners();

    await repository.saveMission(mission);
    _missionActuelle = mission;

    if (!_listeMissions.any((m) => m.numeroTrain == mission.numeroTrain)) {
      _listeMissions.insert(0, mission);
    } else {
      final index = _listeMissions.indexWhere(
        (m) => m.numeroTrain == mission.numeroTrain,
      );
      _listeMissions[index] = mission;
    }

    _isLoading = false;
    notifyListeners();
  }

  // 🛡️ SÉCURISATION DU BOUTON SUPPRIMER : Nettoyage local direct sans async gap
  Future<void> supprimerMission(String numeroTrain) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Suppression physique immédiate dans la base sqflite
      await repository.deleteMission(numeroTrain);

      // 2. Nettoyage instantané de la mémoire locale (UI réactive)
      _listeMissions.removeWhere((m) => m.numeroTrain == numeroTrain);

      if (_missionActuelle?.numeroTrain == numeroTrain) {
        _missionActuelle = _listeMissions.isNotEmpty
            ? _listeMissions.first
            : null;
      }
    } catch (e) {
      debugPrint("Erreur lors de la suppression : $e");
    }
    {
      _isLoading = false;
      notifyListeners(); // On prévient l'accueil de se redessiner sans recharger
    }
  }
}
