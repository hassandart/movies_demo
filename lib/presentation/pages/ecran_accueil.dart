import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movies_demo/presentation/providers/mission_provider.dart';
import 'package:movies_demo/presentation/pages/ecran_saisie.dart';

class EcranAccueilDashboard extends StatefulWidget {
  const EcranAccueilDashboard({super.key});

  @override
  State<EcranAccueilDashboard> createState() => _EcranAccueilDashboardState();
}

class _EcranAccueilDashboardState extends State<EcranAccueilDashboard> {
  // Ajustement dynamique basé sur l'horloge système réelle
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

  @override
  Widget build(BuildContext context) {
    // Blocage strict de l'exception T != dynamic
    final missionProvider = Provider.of<MissionProvider>(context, listen: true);
    final missions = missionProvider.listeMissions;
    final missionActuelle = missionProvider.missionActuelle;
    final int nbAnomalies = missionActuelle?.anomaliesDepart.length ?? 0;

    DateTime dateAffichee = _obtenirDateIndex(_indexJourSelectionne);
    String moisActuel = _moisAnnee[dateAffichee.month - 1];
    String anneeActuelle = dateAffichee.year.toString();

    return Scaffold(
      backgroundColor: const Color(0xFF2980B9),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(80),
                  ),
                ),
                padding: const EdgeInsets.only(
                  top: 60,
                  left: 24,
                  right: 24,
                  bottom: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.menu_rounded,
                          size: 28,
                          color: Color(0xFF2C3E50),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Local OK",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Missions",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        FloatingActionButton(
                          onPressed: () {
                            Provider.of<MissionProvider>(
                              context,
                              listen: false,
                            ).reinitialiserSaisie();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EcranSaisiePremium(),
                              ),
                            );
                          },
                          backgroundColor: const Color(0xFF2980B9),
                          mini: true,
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Aujourd'hui",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        Text(
                          "$moisActuel $anneeActuelle",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 65,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: 5,
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
              const Padding(
                padding: EdgeInsets.only(top: 25.0, left: 24, bottom: 12),
                child: Text(
                  "RACCOURCIS MÉTIERS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildMenuCard(
                      context,
                      title: "Mission",
                      icon: Icons.assignment_outlined,
                      badgeText: nbAnomalies > 0
                          ? nbAnomalies.toString()
                          : null,
                      onTap: () {
                        Provider.of<MissionProvider>(
                          context,
                          listen: false,
                        ).reinitialiserSaisie();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EcranSaisiePremium(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      context,
                      title: "Notes",
                      icon: Icons.edit_note_outlined,
                      onTap: () {},
                    ),
                    _buildMenuCard(
                      context,
                      title: "Thèmes",
                      icon: Icons.palette_outlined,
                      onTap: () {},
                    ),
                    _buildMenuCard(
                      context,
                      title: "Outils",
                      icon: Icons.build_circle_outlined,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 30.0, left: 24, bottom: 12),
                child: Text(
                  "FIL D'ATTENTE DES MISSIONS EN COURS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    if (missions.isEmpty)
                      _buildTaskCard(
                        titre: "Initialiser le train",
                        description: "Aucun service actif détecté en local.",
                        heure: "En attente",
                        icone: Icons.train_outlined,
                        onTap: () {
                          Provider.of<MissionProvider>(
                            context,
                            listen: false,
                          ).reinitialiserSaisie();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EcranSaisiePremium(),
                            ),
                          );
                        },
                      )
                    else
                      ...List.generate(missions.length, (index) {
                        final itemMission = missions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildTaskCard(
                            titre: "Train N° ${itemMission.numeroTrain}",
                            description:
                                "Relation TNR : ${itemMission.gareDepart} ➔ ${itemMission.gareArrivee}\nChef de brigade : ${itemMission.nomChefDeTrain}",
                            heure: itemMission.heureDepart,
                            icone: Icons.directions_train_rounded,
                            onTap: () {
                              Provider.of<MissionProvider>(
                                context,
                                listen: false,
                              ).selectionnerMissionPourModification(
                                itemMission,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EcranSaisiePremium(),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard(int index, String jour, String lettre) {
    final bool active = _indexJourSelectionne == index;
    return GestureDetector(
      onTap: () => setState(() => _indexJourSelectionne = index),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 52,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2980B9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: active
              ? null
              : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              jour,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: active ? Colors.white : const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              lettre,
              style: TextStyle(
                fontSize: 10,
                color: active ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required String titre,
    required String description,
    required String heure,
    required IconData icone,
    Color colorIconBox = const Color(0xFF2980B9),
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorIconBox.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icone, color: colorIconBox, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titre,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    heure,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFEAEBFF), width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4EB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: 28, color: Colors.orange),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2670),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (badgeText != null)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
