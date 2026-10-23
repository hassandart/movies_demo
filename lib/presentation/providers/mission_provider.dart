import 'package:flutter/material.dart';
import 'package:movies_demo/core_utils/database/db_helper.dart';
import 'package:movies_demo/data/models/mission_model.dart';

import '../../domain/entities/mission.dart';
import '../../domain/repositories/mission_repository.dart'; // Import de l'interface

class MissionProvider with ChangeNotifier {
  // 🔑 Le référentiel requis par votre injecteur/main.dart
  final MissionRepository repository;

  // 🚆 UNIFICATION DES ÉTATS : Une variable pour le formulaire, une liste pour l'accueil
  Mission? _missionSelectionnee;
  final List<Mission> _toutesLesMissions = [];

  // 🔥 CORRECTION : Réintroduction du constructeur nommé obligatoire
  MissionProvider({required this.repository});

  // 📖 Getters publics
  Mission? get missionActuelle => _missionSelectionnee;
  List<Mission> get listeMissions => _toutesLesMissions;

  // 🔄 CHARGER TOUTES LES MISSIONS DEPUIS SQLITE
  Future<void> chargerToutesLesMissions() async {
    try {
      // 🟩 CORRECTION : On va chercher toutes les missions dans SQLite
      final db = await DbHelper().database;
      final List<Map<String, dynamic>> maps = await db.query('missions');

      _toutesLesMissions.clear(); // On vide pour éviter les doublons

      for (var map in maps) {
        final numeroTrain = map['numeroTrain'] as String;
        // On récupère les anomalies associées pour chaque train
        final List<Map<String, dynamic>> mapsAnomalies = await db.query(
          'anomalies',
          where: 'numeroTrain = ?',
          whereArgs: [numeroTrain],
        );
        final List<String> listeAnomalies = mapsAnomalies
            .map((row) => row['description'] as String)
            .toList();

        _toutesLesMissions.add(MissionModel.fromMap(map, listeAnomalies));
      }

      notifyListeners(); // 🔥 On prévient l'accueil d'afficher les éléments
    } catch (e) {
      debugPrint("Erreur chargement liste depuis SQLite : $e");
    }
  }

  // 🔍 CHARGER UN TRAIN PRÉCIS (Pour l'écran détails/modification)
  Future<void> chargerMission(String numeroTrain) async {
    try {
      _missionSelectionnee = await repository.obtenirMissionParNumero(
        numeroTrain,
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors du chargement du train $numeroTrain : $e");
    }
  }

  // ➕ AJOUTÉ : Méthode requise par l'écran de saisie en mode création
  Future<void> ajouterNouvelleMission(Mission mission) async {
    await enregistrerMission(mission);
  }

  // 🔄 AJOUTÉ : Méthode requise par l'écran de saisie en mode modification
  Future<void> mettreAJourMission(Mission mission) async {
    await enregistrerMission(mission);
  }

  // 💾 ENREGISTRER SANS ÉCRASER LES AUTRES
  Future<void> enregistrerMission(Mission mission) async {
    try {
      // 1. Écriture physique dans SQLite (via votre interface repository)
      await repository.enregistrerMission(mission);

      // 2. Mise à jour de la liste locale en mémoire pour que les items s'empilent
      final index = _toutesLesMissions.indexWhere(
        (m) => m.numeroTrain == mission.numeroTrain,
      );
      if (index != -1) {
        _toutesLesMissions[index] = mission; // Mode Modification
      } else {
        _toutesLesMissions.add(mission); // Mode Nouvelle Saisie
      }

      _missionSelectionnee = mission;
      notifyListeners(); // 🔥 Rafraîchit l'accueil pour afficher les trains les uns sous les autres
    } catch (e) {
      debugPrint("Erreur lors de l'enregistrement : $e");
      rethrow;
    }
  }

  // ❌ SUPPRIMER UN TRAIN DE LA LISTE
  Future<void> supprimerMission(String numeroTrain) async {
    try {
      await repository.supprimerMission(numeroTrain);
      _toutesLesMissions.removeWhere((m) => m.numeroTrain == numeroTrain);
      if (_missionSelectionnee?.numeroTrain == numeroTrain) {
        _missionSelectionnee = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur suppression : $e");
    }
  }

  // 🧹 Vider le formulaire pour une nouvelle saisie
  void reinitialiserSaisie() {
    _missionSelectionnee = null;
    notifyListeners();
  }
}
