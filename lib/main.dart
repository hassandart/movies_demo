import 'package:flutter/material.dart';

void main() {
  runApp(const MonAppControlleur());
}

class MonAppControlleur extends StatelessWidget {
  const MonAppControlleur({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(
          0xFFFAF7FC,
        ), // Fond légèrement violet/blanc de votre image
      ),
      home: const EcranAccueil(),
    );
  }
}

class EcranAccueil extends StatelessWidget {
  const EcranAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. BARRE SUPÉRIEURE (APPBAR) ORANGE
      appBar: AppBar(
        backgroundColor: Colors.orange, // Couleur orange principale
        title: const Text(
          "Mon Activite",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 2. TITRE PRINCIPAL
            const Text(
              "Mon Agenda",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2670), // Couleur bleu nuit de votre texte
              ),
            ),
            const SizedBox(height: 50), // Espace sous le titre
            // 3. GRILLE DE BOUTONS (2 COLONNES)
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Nombre de colonnes
                crossAxisSpacing: 20, // Espace horizontal entre les boutons
                mainAxisSpacing: 20, // Espace vertical entre les boutons
                children: [
                  _buildMenuCard(context, "Mission", Icons.home),
                  _buildMenuCard(
                    context,
                    "Notes",
                    Icons.hotel,
                  ), // Icône lit représentant vos notes/repos
                  _buildMenuCard(context, "Themes", Icons.train),
                  _buildMenuCard(context, "Outils", Icons.train),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STRUCTURE COMMUNE POUR LES 4 BOUTONS CARRÉS
  Widget _buildMenuCard(BuildContext context, String titre, IconData icone) {
    return InkWell(
      onTap: () {
        // Logique de navigation au clic (ex: Si titre == "Mission", ouvrir l'écran de mission)
        if (titre == "Mission") {
          // Navigator.push(...);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), // Coins arrondis des boutons
          border: Border.all(
            color: Colors.orange, // Bordure orange comme sur votre design
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icone,
              size:
                  55, // Grande taille d'icône pour les contrôleurs en mouvement
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            Text(
              titre,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C2670),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
