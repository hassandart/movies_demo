import 'package:flutter/material.dart';
import 'package:movies_demo/data/models/repositories/mission_repository_impl.dart';
import 'package:provider/provider.dart';

// 🛡️ RECTIFICATION DES CHEMINS : Utilisation des imports absolus package obligatoires pour lib/main.dart

import 'package:movies_demo/presentation/providers/mission_provider.dart';
import 'package:movies_demo/presentation/pages/ecran_saisie.dart';

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
      // Démarre directement sur votre croquis adaptatif ONCF
      home: EcranSaisiePremium(),
    );
  }
}
