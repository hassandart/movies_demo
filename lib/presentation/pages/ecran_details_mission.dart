import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:movies_demo/presentation/pages/ecran_saisie.dart';
import 'package:provider/provider.dart';

import 'package:movies_demo/presentation/providers/mission_provider.dart';

class EcranDetailsMission extends StatelessWidget {
  const EcranDetailsMission({super.key});

  Widget _buildSectionDetail({
    required String titre,
    required List<Widget> elements,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFFFFC400), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          ...elements,
        ],
      ),
    );
  }

  Widget _buildLigneInfo(IconData icon, String cle, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2980B9), size: 18),
          const SizedBox(width: 10),
          Text(
            "$cle : ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              valeur,
              style: const TextStyle(color: Color(0xFF566573), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBilanGlobalFerroviaire({
    required int totalBilletsCasa,
    required List<Widget> garesIntermediaires,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "EXPLOITATION & BILAN DES COMPTAGES",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 95,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC400).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFC400),
                    width: 2.0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.train_rounded,
                      color: Color(0xFF7D6608),
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "CASA-PORT",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF7D6608),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "BC TOTAL",
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$totalBilletsCasa",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(children: garesIntermediaires)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final missionProvider = Provider.of<MissionProvider>(context, listen: true);
    final mission = missionProvider.missionActuelle;

    if (mission == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    int rabat1ere = 0;
    int rabat2eme = 0;
    int kenitra1ere = 0;
    int kenitra2eme = 0;

    // 🧮 LECTURE PARFAITE DE TOUS LES COMPTAGES DE MANIÈRE TOTALEMENT INDÉPENDANTE EN JSON
    if (mission.typeService.isNotEmpty && mission.typeService.startsWith("{")) {
      try {
        final Map<String, dynamic> data = jsonDecode(mission.typeService);
        rabat1ere = data["rabat_1"] ?? 0;
        rabat2eme = data["rabat_2"] ?? 0;
        kenitra1ere = data["kenitra_1"] ?? 0;
        kenitra2eme = data["kenitra_2"] ?? 0;
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F4),
      appBar: AppBar(
        title: Text("Détails Train ${mission.numeroTrain}"),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionDetail(
                  titre: "Itinéraire du Train",
                  elements: [
                    _buildLigneInfo(
                      Icons.directions_train,
                      "Itinéraire",
                      mission.itineraireComplet,
                    ),
                    _buildLigneInfo(
                      Icons.calendar_today,
                      "Date de circulation",
                      mission.date,
                    ),
                    _buildLigneInfo(
                      Icons.access_time,
                      "Horaires effectifs",
                      "${mission.heureDepart} ➔ ${mission.heureArrivee}",
                    ),
                  ],
                ),

                _buildBilanGlobalFerroviaire(
                  totalBilletsCasa: mission.billetsControles,
                  garesIntermediaires: [
                    // --- RABAT AGDAL ---
                    Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E8E8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "RABAT AGDAL",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2C3E50),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFFFC400),
                                    ),
                                  ),
                                  child: Text(
                                    "1ère : $rabat1ere",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Color(0xFF7D6608),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFF2980B9),
                                    ),
                                  ),
                                  child: Text(
                                    "2ème : $rabat2eme",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Color(0xFF2980B9),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // --- KÉNITRA ---
                    Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E8E8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "KÉNITRA",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2C3E50),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFFFC400),
                                    ),
                                  ),
                                  child: Text(
                                    "1ère : $kenitra1ere",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Color(0xFF7D6608),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFF2980B9),
                                    ),
                                  ),
                                  child: Text(
                                    "2ème : $kenitra2eme",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Color(0xFF2980B9),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                _buildSectionDetail(
                  titre: "Brigade Ferroviaire",
                  elements: [
                    _buildLigneInfo(
                      Icons.person,
                      "Chef de Train",
                      mission.nomChefDeTrain,
                    ),
                    _buildLigneInfo(
                      Icons.phone,
                      "Téléphone",
                      mission.numeroChefDeTrain,
                    ),
                    _buildLigneInfo(
                      Icons.confirmation_number_outlined,
                      "N° Rame",
                      "${mission.comptageTerminal}",
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: Colors.redAccent,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      foregroundColor: Colors.redAccent,
                    ),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text(
                      "EFFACER",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      await missionProvider.supprimerMission(
                        mission.numeroTrain,
                      );
                      navigator.pop();
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFFFFC400),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text(
                      "MODIFIER",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EcranSaisiePremium(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
