import 'package:flutter/material.dart';
// Importations absolues sécurisées pour votre projet
import 'package:movies_demo/domain/entities/mission.dart';
import 'package:movies_demo/domain/repositories/mission_repository.dart';

class MissionProvider extends ChangeNotifier {
  final MissionRepository repository;

  Mission? _missionActuelle;
  bool _isLoading = false;

  Mission? get missionActuelle => _missionActuelle;
  bool get isLoading => _isLoading;

  MissionProvider({required this.repository}) {
    chargerMission();
  }

  Future<void> chargerMission() async {
    _isLoading = true;
    notifyListeners();

    _missionActuelle = await repository.getActiveMission();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> enregistrerMission(Mission mission) async {
    await repository.saveMission(mission);
    _missionActuelle = mission;
    notifyListeners();
  }
}
