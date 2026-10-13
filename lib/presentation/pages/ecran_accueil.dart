import 'package:flutter/material.dart';
import 'package:movies_demo/presentation/pages/ecran_saisie.dart';
import 'package:provider/provider.dart';
import 'package:movies_demo/domain/entities/mission.dart';
import 'package:movies_demo/presentation/providers/mission_provider.dart';

import 'ecran_details_mission.dart';

class EcranAccueilDashboard extends StatefulWidget {
  const EcranAccueilDashboard({super.key});

  @override
  State<EcranAccueilDashboard> createState() => _EcranAccueilDashboardState();
}

class _EcranAccueilDashboardState extends State<EcranAccueilDashboard> {
  final DateTime _dateAujourdhui = DateTime.now();
  int _indexJourSelectionne = 0;
  String _rechercheTexte = "";

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

  @override
  void initState() {
    super.initState();
    // 🔥 CHARGEMENT SÉCURISÉ : Force l'application à lire SQLite dès le réveil de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MissionProvider>(
        context,
        listen: false,
      ).chargerToutesLesMissions();
    });
  }

  DateTime _obtenirDateIndex(int index) {
    return _dateAujourdhui.add(Duration(days: index));
  }

  // 🎨 WIDGET DE COMPOSANT : Boutons carrés fixes de votre menu principal
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
          margin: const EdgeInsets.all(4),
          height: 85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
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

  // 🎨 WIDGET DE COMPOSANT : Élément de liste arrondi avec capture tactile intégrale
  Widget _buildMissionItemEtroit(Mission mission) {
    return GestureDetector(
      behavior: HitTestBehavior
          .opaque, // Force toute la surface blanche à réagir au doigt
      onTap: () async {
        // Sécurité anti-gap asynchrone : Extraction des instances avant la pause de lecture SQLite
        final navigator = Navigator.of(context);
        final provider = Provider.of<MissionProvider>(context, listen: false);

        await provider.chargerMission(mission.numeroTrain);
        if (!mounted) return;

        navigator
            .push(
              MaterialPageRoute(
                builder: (context) => const EcranDetailsMission(),
              ),
            )
            .then((_) {
              if (mounted) {
                provider
                    .chargerToutesLesMissions(); // Recharge la liste au retour
              }
            });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF2F4F4), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2980B9).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "N° ${mission.numeroTrain}",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2980B9),
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                mission.date,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                  fontSize: 14,
                ),
              ),
            ),
            if (mission.anomaliesDepart.isNotEmpty) ...[
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 18,
              ),
              const SizedBox(width: 14),
            ],
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.black26,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final missionProvider = Provider.of<MissionProvider>(context, listen: true);
    final toutesLesMissions = missionProvider.listeMissions;

    // Filtre dynamique appliqué en temps réel
    final listMissionsFiltrees = toutesLesMissions.where((mission) {
      final rechercheId = _rechercheTexte.trim().toLowerCase();
      if (rechercheId.isEmpty) return true;
      return mission.numeroTrain.toLowerCase().contains(rechercheId) ||
          mission.date.toLowerCase().contains(rechercheId);
    }).toList();

    DateTime dateAffichee = _obtenirDateIndex(_indexJourSelectionne);
    String moisActuel = _moisAnnee[dateAffichee.month - 1];
    String anneeActuelle = dateAffichee.year.toString();

    return Scaffold(
      backgroundColor: const Color(0xFF2980B9),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎫 BLOC EN-TÊTE BLANCHE CONTEMPORAIN
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
                    "Tableau de Bord",
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

                  // CALENDRIER HORIZONTAL COMPACT
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
                        String chiffreJour = jourCalcule.day.toString().padLeft(
                          2,
                          '0',
                        );
                        String lettreJour =
                            _lettresJours[jourCalcule.weekday - 1];
                        return _buildDateCard(index, chiffreJour, lettreJour);
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // BARRE DE RECHERCHE TEXTE ÉPURÉE
                  TextField(
                    onChanged: (valeur) => setState(() {
                      _rechercheTexte = valeur;
                    }),
                    style: const TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: "Rechercher par n° de train ou date...",
                      hintStyle: TextStyle(
                        color: Colors.grey.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF2980B9),
                        size: 20,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFFFC400),
                          width: 1.5,
                        ), // Focus Jaune ONCF
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // 🎛️ GRILLE FIXE DES 4 BOUTONS MENUS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildMenuButton(
                        icon: Icons.edit_note_rounded,
                        label: "Mission",
                        color: const Color(0xFF2980B9),
                        onTap: () {
                          missionProvider.reinitialiserSaisie();
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EcranSaisiePremium(),
                                ),
                              )
                              .then((valeurDeRetour) {
                                // 🟩 CORRECTION : Ajout du paramètre obligatoire pour corriger le type
                                if (mounted) {
                                  missionProvider.chargerToutesLesMissions();
                                }
                              });
                        },
                      ),

                      _buildMenuButton(
                        icon: Icons.analytics_rounded,
                        label: "Statistiques",
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
                        label: "Réglages",
                        color: Colors.blueGrey,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                "TRAJETS PLANIFIÉS DU JOUR",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ),
            // 🛤️ ZONE DE LISTE DE TRAJETS ASSURÉE PAR EXPANSED
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFF2980B9),
                child: listMissionsFiltrees.isEmpty
                    ? const Center(
                        child: Text(
                          "Aucun trajet enregistré",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: listMissionsFiltrees.length,
                        itemBuilder: (context, index) {
                          return _buildMissionItemEtroit(
                            listMissionsFiltrees[index],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
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
