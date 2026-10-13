import 'package:flutter/material.dart';
import 'package:movies_demo/presentation/pages/ecran_saisie.dart';
import 'package:provider/provider.dart';
import 'package:movies_demo/domain/entities/mission.dart';
import 'package:movies_demo/presentation/providers/mission_provider.dart';

class EcranDetailsMission extends StatelessWidget {
  const EcranDetailsMission({super.key});

  // 🎨 WIDGET PERSONNALISÉ : Bloc d'information avec ligne jaune ONCF
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

  // 💾 LOGIQUE : Fonction de simulation du partage de rapport de brigade
  void _partagerMission(BuildContext context, Mission mission) {
    final String texteRapport =
        """
🚆 RAPPORT DE BRIGADE ONCF - TRAIN ${mission.numeroTrain}
📅 Date : ${mission.date} | Parcours : ${mission.itineraireComplet}
👤 Chef de train : ${mission.nomChefDeTrain}
📊 Comptages Voyageurs :
- 1ère Classe : ${mission.voyageursPremiereCl} | 2nde Classe : ${mission.voyageursSecondeCl}
- Comptage Rabat : ${mission.comptageRabat} | Terminal : ${mission.comptageTerminal}
- Billets Contrôlés : ${mission.billetsControles}
⚠️ Anomalies constatées : ${mission.anomaliesDepart.isEmpty ? "Aucune" : mission.anomaliesDepart.join(", ")}
    """;

    // Affichage d'un aperçu du partage sur le portable
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

  // ❌ LOGIQUE : Boîte de dialogue de confirmation avant suppression SQLite
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
              Navigator.pop(ctx); // Ferme le dialogue
              await provider.supprimerMission(
                numeroTrain,
              ); // Supprime des deux tables
              if (!context.mounted) return;
              Navigator.pop(context); // Revient à l'accueil
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 📜 ZONE D'INFORMATION DÉFILANTE
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // Secteur 1 : Horaires & Trajet
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

                  // Secteur 2 : VARIABLES DE COMPTAGE ONCF
                  _buildSectionDetail(
                    titre: "Comptages & Statistiques Brigade",
                    elements: [
                      _buildLigneInfo(
                        Icons.confirmation_number_rounded,
                        "Billets Contrôlés",
                        "${mission.billetsControles}",
                      ),
                      _buildLigneInfo(
                        Icons.looks_one_rounded,
                        "Voyageurs 1ère Classe",
                        "${mission.voyageursPremiereCl}",
                      ),
                      _buildLigneInfo(
                        Icons.looks_two_rounded,
                        "Voyageurs 2nde Classe",
                        "${mission.voyageursSecondeCl}",
                      ),
                      _buildLigneInfo(
                        Icons.stacked_bar_chart,
                        "Comptage Rabat",
                        "${mission.comptageRabat}",
                      ),
                      _buildLigneInfo(
                        Icons.pin_drop,
                        "Comptage Terminal",
                        "${mission.comptageTerminal}",
                      ),
                    ],
                  ),

                  // Secteur 3 : Anomalies
                  _buildSectionDetail(
                    titre: "Anomalies au départ",
                    elements: mission.anomaliesDepart.isEmpty
                        ? [
                            const Text(
                              "✅ Aucune anomalie signalée au départ",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]
                        : mission.anomaliesDepart
                              .map(
                                (anomalie) => Text(
                                  "• $anomalie",
                                  style: const TextStyle(
                                    color: Color(0xFF2C3E50),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                              .toList(),
                  ),
                ],
              ),
            ),

            // 🎛️ BARRÈ D'ACTIONS D'OPTIONS FIXE TOUT EN BAS (Design Premium)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  // Bouton Partager (Bleu)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _partagerMission(context, mission),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text("Partager"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2980B9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Bouton Modifier (Orange)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // En mode modification, la mission actuelle est déjà chargée dans le Provider
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EcranSaisiePremium(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text("Modifier"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Bouton Supprimer (Rouge)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmerSuppression(
                        context,
                        missionProvider,
                        mission.numeroTrain,
                      ),
                      icon: const Icon(Icons.delete_forever_rounded, size: 18),
                      label: const Text("Effacer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
