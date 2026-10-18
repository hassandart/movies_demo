import 'package:flutter/material.dart';
import 'package:movies_demo/presentation/pages/ecran_saisie.dart';

import 'package:provider/provider.dart';
import 'package:movies_demo/domain/entities/mission.dart';
import 'package:movies_demo/presentation/providers/mission_provider.dart';

class EcranDetailsMission extends StatelessWidget {
  const EcranDetailsMission({super.key});

  // 🧱 WIDGET 1 : Le moule standard pour les cartes Voyage et Horaires / Anomalies
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
          left: BorderSide(
            color: Color(0xFFFFC400),
            width: 4,
          ), // Ligne Jaune ONCF
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

  // 🧱 WIDGET 2 : Le moule pour écrire une ligne simple d'information (icône + texte)
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

  // 🟩 WIDGET 3 : VOTRE CONTENEUR REARCHITECTURÉ (Casa-Port à gauche, les Gares à droite)
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
              // ⬅️ SECTION GAUCHE : CASA-PORT AVEC SES BILLETS CONTRÔLÉS (BC)
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
                  ), // Ligne Jaune ONCF
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
                      "$totalBilletsCasa", // Reçoit dynamiquement le volume SQLite
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
              // ➡️ SECTION DROITE : LES CASES DE GARES INTERMÉDIAIRES
              Expanded(child: Column(children: garesIntermediaires)),
            ],
          ),
        ],
      ),
    );
  }

  // 🟩 WIDGET 4 : Le sous-moule compact pour chaque gare à droite (1ère / 2nde classe)
  Widget _buildCaseGareVoyageurs({
    required String nomGare,
    required int qte1ere,
    required int qte2nde,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E8E8), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nomGare.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF2C3E50),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // Badge 1ère classe
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFFC400),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    "1ère : $qte1ere",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7D6608),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Badge 2nde classe
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF2980B9),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    "2nde : $qte2nde",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4F72),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 💾 LOGIQUE : Fonction de simulation du partage de rapport de brigade
  void _partagerMission(BuildContext context, Mission mission) {
    final String texteRapport =
        """
🚆 RAPPORT DE BRIGADE ONCF - TRAIN ${mission.numeroTrain}
📅 Date : ${mission.date} | Parcours : ${mission.itineraireComplet}
👤 Chef de train : ${mission.nomChefDeTrain}
📊 Billets Contrôlés : ${mission.billetsControles}
⚠️ Anomalies constatées : ${mission.anomaliesDepart.isEmpty ? "Aucune" : mission.anomaliesDepart.join(", ")}
    """;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "📋 Rapport textuel copié pour partage (WhatsApp/Email)",
        ),
        backgroundColor: const Color(0xFF2980B9),
        action: SnackBarAction(
          label: "VOIR",
          textColor: Colors.white,
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Aperçu du Rapport"),
                content: SingleChildScrollView(child: Text(texteRapport)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ❌ LOGIQUE : Confirmation de suppression
  void _confirmerSuppression(
    BuildContext context,
    MissionProvider provider,
    String numeroTrain,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer la mission ?"),
        content: Text(
          "Voulez-vous vraiment effacer le train N° $numeroTrain de la base SQLite locale ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("ANNULER", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.supprimerMission(numeroTrain);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text(
              "SUPPRIMER",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final missionProvider = Provider.of<MissionProvider>(context);
    final mission = missionProvider.missionActuelle;

    if (mission == null) {
      return const Scaffold(
        body: Center(child: Text("Aucune mission chargée")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2980B9),
      appBar: AppBar(
        title: Text("Détails Train ${mission.numeroTrain}"),
        backgroundColor: const Color(0xFF2980B9),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _partagerMission(context, mission),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                // 🔥 SÉCURITÉ COMPILATION : Aucun mot-clé const n'est écrit devant ce tableau d'enfants !
                children: [
                  // 1️⃣ SECTEUR 1 : Voyage et Horaires
                  _buildSectionDetail(
                    titre: "Voyage et Horaires",
                    elements: [
                      _buildLigneInfo(
                        Icons.train,
                        "Numéro de Train",
                        mission.numeroTrain,
                      ),
                      _buildLigneInfo(
                        Icons.calendar_today,
                        "Date du trajet",
                        mission.date,
                      ),
                      _buildLigneInfo(
                        Icons.near_me,
                        "Itinéraire",
                        mission.itineraireComplet,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildLigneInfo(
                              Icons.access_time,
                              "Départ",
                              mission.heureDepart,
                            ),
                          ),
                          Expanded(
                            child: _buildLigneInfo(
                              Icons.update,
                              "Arrivée",
                              mission.heureArrivee,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // 2️⃣ SECTEUR 2 : Brigade Ferroviaire (Conservé et bien ordonné)
                  _buildSectionDetail(
                    titre: "Brigade Ferroviaire",
                    elements: [
                      _buildLigneInfo(
                        Icons.person,
                        "Chef de Train",
                        mission.nomChefDeTrain,
                      ),
                      _buildLigneInfo(
                        Icons.pin_rounded,
                        "N° Rame Matériel",
                        mission.comptageTerminal == 0
                            ? "Non renseigné"
                            : "${mission.comptageTerminal}",
                      ),
                    ],
                  ),
                  // =========================================================================
                  // 3️⃣ SECTEUR 3 : LE CONTENEUR D'OUTPUT EXACT DE L'IMAGE (CASA VS ARRÊTS 1/2 CL)
                  // =========================================================================
                  _buildBilanGlobalFerroviaire(
                    totalBilletsCasa: mission.billetsControles,
                    garesIntermediaires: [
                      _buildCaseGareVoyageurs(
                        nomGare: "Rabat Agdal",
                        qte1ere: mission.voyageursPremiereCl,
                        qte2nde: mission.voyageursSecondeCl,
                      ),
                      _buildCaseGareVoyageurs(
                        nomGare: "Kénitra",
                        qte1ere: mission.comptageRabat,
                        qte2nde: mission.voyageursSecondeCl,
                      ),
                    ],
                  ),
                  // 4️⃣ SECTEUR 4 : Incidents & Observations
                  _buildSectionDetail(
                    titre: "Incidents & Observations",
                    elements: [
                      Text(
                        mission.anomaliesDepart.isEmpty
                            ? "Aucune anomalie constatée au départ."
                            : mission.anomaliesDepart.join("\n"),
                        style: const TextStyle(
                          color: Color(0xFF566573),
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 🛠️ BARRE DE BOUTONS INFÉRIEURE
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmerSuppression(
                        context,
                        missionProvider,
                        mission.numeroTrain,
                      ),
                      icon: const Icon(
                        Icons.delete_sweep_rounded,
                        color: Colors.redAccent,
                      ),
                      label: const Text(
                        "EFFACER",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EcranSaisiePremium(),
                              ),
                            )
                            .then((_) {
                              if (context.mounted) {
                                missionProvider.chargerMission(
                                  mission.numeroTrain,
                                );
                              }
                            });
                      },
                      icon: const Icon(
                        Icons.edit_road_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "MODIFIER",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC400),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
