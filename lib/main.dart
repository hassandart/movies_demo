import 'package:flutter/material.dart';

import 'data/models/repositories/mission_repository_impl.dart';

import 'package:provider/provider.dart';
// Liens vers votre architecture propre (Clean Architecture)

import 'package:movies_demo/presentation/providers/mission_provider.dart';
import 'package:movies_demo/presentation/pages/ecran_accueil.dart';

void main() {
  // Ligne essentielle pour s'assurer que sqflite s'initialise correctement sur le smartphone
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MissionProvider(repository: MissionRepositoryImpl()),
        ),
      ],
      child: const MonAppControlleurFinal(),
    ),
  );
}

class MonAppControlleurFinal extends StatelessWidget {
  const MonAppControlleurFinal({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contrôleur Train Sync',
      // Appelle directement votre nouveau tableau de bord asymétrique connecté à sqflite
      home: EcranAccueilDashboard(),
    );
  }
}
