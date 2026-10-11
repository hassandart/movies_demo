import 'package:flutter/material.dart';
import 'package:movies_demo/presentation/pages/ecran_saisie.dart';

import 'package:provider/provider.dart';

import '../providers/mission_provider.dart';

class EcranAccueilDashboard extends StatefulWidget {
  const EcranAccueilDashboard({super.key});

  @override
  State<EcranAccueilDashboard> createState() => _EcranAccueilDashboardState();
}

class _EcranAccueilDashboardState extends State<EcranAccueilDashboard> {
  final DateTime _dateAujourdhui = DateTime.now();
  int _indexJourSelectionne = 0;

  final List<String> _lettresJours = ["L", "M", "M", "J", "V", "S", "D"];
  final List<String> _moisAnnee = [
    "Janvier",
    "Février",
    "Mars",
    "Avril",
    "Mai",
    "Juin",
    "Juillet",
    "Août",
    "Septembre",
    "Octobre",
    "Novembre",
    "Décembre",
  ];

  DateTime _obtenirDateIndex(int index) {
    return _dateAujourdhui.add(Duration(days: index));
  }

  // 🎨 FONCTION GRAPHIQUE : Crée un bouton menu carré élégant pour votre grille ONCF
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(6),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final missionProvider = Provider.of<MissionProvider>(context, listen: true);
    final missions = missionProvider.listeMissions;

    DateTime dateAffichee = _obtenirDateIndex(_indexJourSelectionne);
    String moisActuel = _moisAnnee[dateAffichee.month - 1];
    String anneeActuelle = dateAffichee.year.toString();

    return PopScope(
      canPop: true, // 🟩 Correction : Autorise la fermeture propre de l'application depuis l'accueil
      child: Scaffold(
        backgroundColor: const Color(0xFF2980B9),
        body: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎫 SECTION EN-TÊTE BLANCHE STYLE CONTEMPORAIN
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(60),
                  ),
                ),
                padding: const EdgeInsets.only(
                  top: 50,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.train_rounded,
                          size: 26,
                          color: Color(0xFF2980B9),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Local OK",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Agenda ACT",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Aujourd'hui",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        Text(
                          "$moisActuel $anneeActuelle",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // 🗓️ SÉLECTEUR DE DATE HORIZONTAL COMPACT
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          DateTime jourCalcule = _dateAujourdhui.add(
                            Duration(days: index),
                          );
                          String chiffreJour = jourCalcule.day
                              .toString()
                              .padLeft(2, '0');
                          String lettreJour =
                              _lettresJours[jourCalcule.weekday - 1];
                          return _buildDateCard(index, chiffreJour, lettreJour);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // 🎛️ 1ÈRE UI INTERNÉ : GRILLE DES 4 BOUTONS MENUS PRINCIPAUX
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildMenuButton(
                          icon: Icons.edit_note_rounded,
                          label: "Mission",
                          color: const Color(0xFF2980B9),
                          onTap: () {
                            // 🟩 Action demandée : Clique pour ouvrir la saisie
                            Provider.of<MissionProvider>(
                              context,
                              listen: false,
                            ).reinitialiserSaisie();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EcranSaisiePremium(),
                              ),
                            );
                          },
                        ),
                        _buildMenuButton(
                          icon: Icons.analytics_rounded,
                          label: "Thémes",
                          color: const Color(0xFF27AE60),
                          onTap: () {},
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildMenuButton(
                          icon: Icons.history_toggle_off_rounded,
                          label: "Historique",
                          color: Colors.orange,
                          onTap: () {},
                        ),
                        _buildMenuButton(
                          icon: Icons.settings_rounded,
                          label: "Outils",
                          color: Colors.blueGrey,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Titre de la zone de liste étirée

              // 🛤️ LISTE ÉTIRÉE SUR TOUTE LA LONGUEUR (FOND BLEU)
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF2980B9),
                  child: missions.isEmpty
                      ? const Center(
                          // child: Text(
                          //   "Aucune mission enregistrée pour ce jour",
                          //   style: TextStyle(
                          //     color: Colors.white60,
                          //     fontSize: 13,
                          //     fontWeight: FontWeight.w500,
                          //   ),
                          // ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: missions.length,
                          itemBuilder: (context, index) {
                            final mission = missions[index];
                            return _buildMissionItemEtroit(mission);
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionItemEtroit(dynamic mission) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF2F4F4), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2980B9).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "N° ${mission.numeroTrain}",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF2980B9),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              mission.itineraireComplet,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (mission.anomaliesDepart.isNotEmpty) ...[
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 12),
          ],
          GestureDetector(
            onTap: () async {
              await Provider.of(
                context,
                listen: false,
              ).chargerMission(mission.numeroTrain);
              if (!mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EcranSaisiePremium(),
                ),
              );
            },
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.black26,
              size: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(int index, String chiffreJour, String lettreJour) {
    final bool estSelectionne = _indexJourSelectionne == index;
    return GestureDetector(
      onTap: () => setState(() => _indexJourSelectionne = index),
      child: Container(
        width: 46,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: estSelectionne
              ? const Color(0xFF2980B9)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lettreJour,
              style: TextStyle(
                color: estSelectionne ? Colors.white70 : Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              chiffreJour,
              style: TextStyle(
                color: estSelectionne ? Colors.white : const Color(0xFF2C3E50),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
