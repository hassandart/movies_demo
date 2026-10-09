import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 🛡️ RECONNEXION ARCHITECTURE PROPRE : Chemins directs
import '../providers/mission_provider.dart';
import 'ecran_saisie.dart';

class EcranAccueilDashboard extends StatefulWidget {
  const EcranAccueilDashboard({super.key});

  @override
  State<EcranAccueilDashboard> createState() => _EcranAccueilDashboardState();
}

class _EcranAccueilDashboardState extends State<EcranAccueilDashboard> {
  // Alignement dynamique sur l'horloge interne de votre terminal Honeywell
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
    // 🛡️ SÉCURISATION DU MANAGER D'ÉTAT SANS FUITE DYNAMIC
    final missionProvider = Provider.of<MissionProvider>(context, listen: true);
    final missions = missionProvider.listeMissions;

    DateTime dateAffichee = _obtenirDateIndex(_indexJourSelectionne);
    String moisActuel = _moisAnnee[dateAffichee.month - 1];
    String anneeActuelle = dateAffichee.year.toString();

    // 🛡️ PROTECTION DU BOUTON RETOUR : Système anti-fermeture
    return PopScope(
      canPop: false, // 🛑 Bloque de manière absolue la sortie vers l'OS Android/Honeywell
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        // 🔄 Redirection forcée en boucle fermée vers votre croquis de saisie
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const EcranSaisiePremium()),
          (route) => false,
        );
      },
      child: Scaffold(
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
                          IconButton(
                            icon: const Icon(
                              Icons.menu_rounded,
                              size: 28,
                              color: Color(0xFF2C3E50),
                            ),
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EcranSaisiePremium(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: .1),
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
                          IconButton(
                            icon: const Icon(
                              Icons.edit_note_rounded,
                              color: Color(0xFF2980B9),
                              size: 32,
                            ),
                            onPressed: () {
                              Provider.of<MissionProvider>(
                                context,
                                listen: false,
                              ).reinitialiserSaisie();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EcranSaisiePremium(),
                                ),
                                (route) => false,
                              );
                            },
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
                            return _buildDateCard(
                              index,
                              chiffreJour,
                              lettreJour,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(top: 25.0, left: 24, bottom: 12),
                  child: Text(
                    "HISTORIQUE DES TOURNÉES VALIDÉES",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: missions.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                "Aucun train enregistré aujourd'hui.",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: missions.length,
                          itemBuilder: (context, index) {
                            final item = missions[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.train_rounded,
                                  color: Color(0xFF2980B9),
                                ),
                                title: Text(
                                  "Train N° ${item.numeroTrain}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "Axe : ${item.gareArrivee}\nDate : ${item.date}",
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard(int index, String chiffre, String lettre) {
    final bool estSelectionne = _indexJourSelectionne == index;
    return GestureDetector(
      onTap: () => setState(() => _indexJourSelectionne = index),
      child: Container(
        width: 50,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: estSelectionne
              ? const Color(0xFF2980B9)
              : const Color(0xFFF2F4F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lettre,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: estSelectionne ? Colors.white70 : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              chiffre,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: estSelectionne ? Colors.white : const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
