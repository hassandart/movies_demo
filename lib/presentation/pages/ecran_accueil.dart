import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movies_demo/presentation/providers/mission_provider.dart';

import 'ecran_saisie.dart';

class EcranAccueilDashboard extends StatelessWidget {
  const EcranAccueilDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final missionProvider = context.watch<MissionProvider>();
    final mission = missionProvider.missionActuelle;
    final int nbAnomalies = mission?.anomaliesDepart.length ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF2980B9), // Fond bleu de l'image
      body: SafeArea(
        top: false, // Permet au bloc blanc de monter tout en haut
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------
              // LE BLOC BLANC DU HAUT (FORME ASYMÉTRIQUE)
              // ----------------------------------------------------
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
                    // Barre supérieure
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

                    // Titre principal et bouton d'action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "My Task",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        FloatingActionButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EcranSaisiePremium(),
                            ),
                          ),
                          backgroundColor: const Color(0xFF2980B9),
                          mini: true,
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Sous-titre de la date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Today",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        Text(
                          "Monday, 1 June",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Calendrier horizontal défilant
                    SizedBox(
                      height: 65,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildDateCard("01", "M", active: true),
                          _buildDateCard("02", "T"),
                          _buildDateCard("03", "W"),
                          _buildDateCard("04", "T"),
                          _buildDateCard("05", "F"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ESPACE TRANSITION AVANT LA ZONE DES CARTES DANS LE BLEU
              const Padding(
                padding: EdgeInsets.only(top: 24.0, left: 24, bottom: 10),
                child: Text(
                  "SERVICES & ALERTES EN COURS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              // ----------------------------------------------------
              // ZONE INFERIEURE DÉFILANTE DANS LE FOND BLEU
              // ----------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // S'il n'y a pas de train en base, on affiche une carte d'invite
                    if (mission == null)
                      _buildTaskCard(
                        titre: "Initialiser le train",
                        description: "Aucun service actif détecté en local.",
                        heure: "En attente",
                        icone: Icons.train_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EcranSaisiePremium(),
                          ),
                        ),
                      )
                    else ...[
                      // S'il y a une mission, on affiche les informations du train
                      _buildTaskCard(
                        titre: "Mission : ${mission.numeroTrain}",
                        description:
                            "Responsable de bord : ${mission.nomChefDeTrain}",
                        heure: mission.heureDepart,
                        icone: Icons.directions_train_rounded,
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),

                      // S'il y a des anomalies, on génère une carte par anomalie enregistrée
                      if (nbAnomalies > 0)
                        ...List.generate(nbAnomalies, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildTaskCard(
                              titre: "Alerte : Anomalie détectée",
                              description: mission.anomaliesDepart[index],
                              heure: "Urgent",
                              icone: Icons.warning_amber_rounded,
                              colorIconBox: const Color(0xFFF1C40F),
                              onTap: () {},
                            ),
                          );
                        })
                      else
                        _buildTaskCard(
                          titre: "État du matériel",
                          description:
                              "Aucune anomalie signalée à bord de la rame.",
                          heure: "OK",
                          icone: Icons.check_circle_outline_rounded,
                          colorIconBox: Colors.green,
                          onTap: () {},
                        ),
                    ],

                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
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
                    const SizedBox(height: 12),

                    // LES 4 ICONES DU MENU (EN BAS ET ENTIÈREMENT SCROLLABLES)
                    GridView.count(
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
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EcranSaisiePremium(),
                            ),
                          ),
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
                    const SizedBox(
                      height: 40,
                    ), // Espace de confort en fin de défilement
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET POUR LES CASES DU CALENDRIER DU HAUT
  Widget _buildDateCard(String jour, String lettre, {bool active = false}) {
    return Container(
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
    );
  }

  // WIDGET COMPOSANT : LES CARTES DE TÂCHES BLANCHES
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
                              fontSize: 18,
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

  // DESIGN DES BOUTONS DE LA GRILLE (LIGNES FINES ET SAAS LOOK)
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
