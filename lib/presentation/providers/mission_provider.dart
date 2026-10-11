import 'package:flutter/material.dart';

import '../../domain/entities/mission.dart';
import '../../domain/repositories/mission_repository.dart'; // Import de l'interface abstraite

class MissionProvider with ChangeNotifier {
  // 🔑 Le référentiel utilise désormais l'interface abstraite (plus flexible)
  final MissionRepository repository;
  // 2️⃣ AJOUTEZ CE GETTER POUR LA LISTE DES MISSIONS :
  List<Mission> get listeMissions =>
      _missionActuelle != null ? [_missionActuelle!] : [];

  // 🔥 CORRECTION : Définition du paramètre nommé requis par votre application
  MissionProvider({required this.repository});

  // 🚆 État local : stocke la mission actuellement sélectionnée
  Mission? _missionActuelle;

  // 📖 Getter public
  Mission? get missionActuelle => _missionActuelle;

  // 🔄 CHARGER UNE MISSION DEPUIS SQFLITE
  Future<void> chargerMission(String numeroTrain) async {
    try {
      _missionActuelle = await repository.obtenirMissionParNumero(numeroTrain);
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors du chargement de la mission $numeroTrain : $e");
    }
  }

  // 💾 ENREGISTRER OU MODIFIER UNE MISSION
  Future<void> enregistrerMission(Mission mission) async {
    try {
      await repository.enregistrerMission(mission);
      _missionActuelle = mission;
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de l'enregistrement de la mission : $e");
      rethrow;
    }
  }

  // ❌ SUPPRIMER UNE MISSION
  Future<void> supprimerMission(String numeroTrain) async {
    try {
      await repository.supprimerMission(numeroTrain);
      if (_missionActuelle?.numeroTrain == numeroTrain) {
        _missionActuelle = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de la suppression de la mission : $e");
    }
  }

  // 1️⃣ REMPLACEZ reinitialiserMission() PAR :
  void reinitialiserSaisie() {
    _missionActuelle = null;
    notifyListeners();
  }
}
