import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movies_demo/domain/entities/mission.dart';
import 'package:movies_demo/presentation/providers/mission_provider.dart';

import 'ecran_accueil.dart'; // Vérifiez si c'est 'ecran_accueil.dart' ou 'ecran_accueil_dashboard.dart'

class EcranSaisiePremium extends StatefulWidget {
  const EcranSaisiePremium({super.key});

  @override
  State<EcranSaisiePremium> createState() => _EcranSaisiePremiumState();
}

class _EcranSaisiePremiumState extends State<EcranSaisiePremium> {
  final _formKey = GlobalKey<FormState>();
  bool _estEnModeModification = false;
  String _numTrainOrigine = "";
  String _destinationChoisie = "";

  late TextEditingController _numTrainController;
  late TextEditingController _dateController;
  late TextEditingController _departController;
  late TextEditingController _arriveeController;
  late TextEditingController _nomChefController;
  late TextEditingController _telephoneController;
  late TextEditingController _rameController;
  late TextEditingController _anomaliesController;

  // 📊 Décompté et réactivé : Configuration de vos 4 boutons d'axes ONCF
  final List<Map<String, String>> _boutonsDestinations = [
    {"label": "K", "nom": "KENITRA", "code": "250"},
    {"label": "EJ", "nom": "EL JADIDA", "code": "610"},
    {"label": "S", "nom": "SETTAT", "code": "139"},
    {"label": "A", "nom": "AÉROPORT MED V", "code": "190"},
  ];

  @override
  void initState() {
    super.initState();

    final missionActuelle = context.read<MissionProvider>().missionActuelle;
    _estEnModeModification = missionActuelle != null;

    // 🔥 Initialisation immédiate pour éviter le LateInitializationError
    _anomaliesController = TextEditingController(
      text:
          (missionActuelle != null &&
              missionActuelle.anomaliesDepart.isNotEmpty)
          ? missionActuelle.anomaliesDepart.join("\n")
          : '',
    );

    final String dateFormatee =
        "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}";

    _numTrainController = TextEditingController(
      text: missionActuelle?.numeroTrain ?? '',
    );
    _dateController = TextEditingController(
      text: missionActuelle?.date ?? dateFormatee,
    );
    _departController = TextEditingController(
      text: missionActuelle?.heureDepart ?? '11:05',
    );
    _arriveeController = TextEditingController(
      text: missionActuelle?.heureArrivee ?? '12:25',
    );
    _nomChefController = TextEditingController(
      text: missionActuelle?.nomChefDeTrain ?? '',
    );
    _telephoneController = TextEditingController(
      text: missionActuelle?.numeroChefDeTrain ?? '',
    );
    _rameController = TextEditingController(
      text: (missionActuelle == null || missionActuelle.voyageursSecondeCl == 0)
          ? ''
          : "${missionActuelle.voyageursSecondeCl}",
    );

    if (_estEnModeModification) {
      _numTrainOrigine = missionActuelle!.numeroTrain;
      _destinationChoisie = missionActuelle.gareArrivee;
    }
  }

  @override
  void dispose() {
    _numTrainController.dispose();
    _dateController.dispose();
    _departController.dispose();
    _arriveeController.dispose();
    _nomChefController.dispose();
    _telephoneController.dispose();
    _rameController.dispose();
    _anomaliesController
        .dispose(); // 🟩 CORRECTION : Libération du contrôleur d'anomalies
    super.dispose();
  }

  void _sauvegarderEtBasculerVersAccueil() async {
    if (_formKey.currentState!.validate() && _destinationChoisie.isNotEmpty) {
      // 🟩 CORRECTION : Capture et formatage dynamique de votre champ d'anomalies
      final texteAnomalies = _anomaliesController.text.trim();
      final List<String> listeAnomalies = texteAnomalies.isEmpty
          ? const []
          : [texteAnomalies];

      final nouvelleMission = Mission(
        numeroTrain: _numTrainController.text.trim().isEmpty
            ? "0"
            : _numTrainController.text.trim(),
        date: _dateController.text.trim(),
        heureDepart: _departController.text.trim(),
        heureArrivee: _arriveeController.text.trim(),
        gareDepart: "CASA-PORT",
        gareArrivee: _destinationChoisie,
        nomChefDeTrain: _nomChefController.text.trim(),
        numeroChefDeTrain: _telephoneController.text.trim(),
        anomaliesDepart:
            listeAnomalies, // 🟩 CORRECTION : Liaison avec SQLite rétablie
        billetsControles: 0,
        voyageursPremiereCl: 0,
        voyageursSecondeCl: int.tryParse(_rameController.text.trim()) ?? 0,
        comptageRabat: 0,
        comptageTerminal: 0,
        typeService: "TRAIN NOMINAL",
      );

      final missionProvider = Provider.of<MissionProvider>(
        context,
        listen: false,
      );

      if (_estEnModeModification &&
          _numTrainOrigine != nouvelleMission.numeroTrain) {
        await missionProvider.supprimerMission(_numTrainOrigine);
      }

      await missionProvider.enregistrerMission(nouvelleMission);
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const EcranAccueilDashboard()),
        (route) => false,
      );
    }
  }

  // 🎨 FONCTION DE GRAPHISME : Les champs standards équipés de leur LIGNE JAUNE
  Widget _buildStandardField({
    required TextEditingController controller,
    required IconData icone, // Paramètre requis validé
    String? label,
    String? hintText,
    bool lectureSeule = false,
    bool estNumerique = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: lectureSeule,
      keyboardType: estNumerique ? TextInputType.number : TextInputType.text,
      style: const TextStyle(
        color: Color(0xFF2C3E50),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      validator: (val) =>
          val == null || val.trim().isEmpty ? "Champ requis" : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        hintStyle: TextStyle(
          color: Colors.grey.withValues(alpha: 0.6),
          fontSize: 13,
        ),
        prefixIcon: Icon(icone, color: const Color(0xFF2980B9), size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),

        // 🔥 Ligne jaune ONCF par défaut sous le champ blanc
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFFC400), width: 2.0),
        ),
        // 🔥 Ligne jaune plus épaisse lors du clic
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFFC400), width: 3.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  // 🎨 FONCTION DE GRAPHISME : Le Grand Champ d'anomalies autonome équipé de sa LIGNE JAUNE
  Widget _buildGrandChampAnomalies({
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      minLines: 4,
      keyboardType: TextInputType.multiline,
      style: const TextStyle(
        color: Color(0xFF2C3E50),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: "Saisir une anomalie si nécessaire...",
        hintStyle: TextStyle(
          color: Colors.grey.withValues(alpha: 0.6),
          fontSize: 13,
        ),
        prefixIcon: const Align(
          alignment: Alignment.topLeft,
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: Padding(
            padding: EdgeInsets.only(left: 12, top: 14, right: 8),
            child: Icon(
              Icons.report_problem_rounded,
              color: Colors.orange,
              size: 20,
            ),
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),

        // 🔥 Ligne jaune par défaut
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFFC400), width: 2.0),
        ),
        // 🔥 Ligne jaune lors du clic
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFFC400), width: 3.0),
        ),
      ),
    );
  }

  // 🎨 FONCTION DE GRAPHISME : Le bandeau d'affichage publicitaire / informatif requis
  Widget _buildEcranAccueilPublicitaire() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC400).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFFC400),
          width: 1.5,
        ), // Encadrement jaune
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFFFC400), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Note Brigade : S'assurer de la présence des kits de sécurité avant le départ de Casa-Port.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 FONCTION DE GRAPHISME : Le conteneur de carte blanche
  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2980B9),
      appBar: AppBar(
        title: const Text(
          "Début Mission",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF2980B9),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // 📊 1. BANDEAU DE SELECTION D'AXE ONCF (K, EJ, S, A)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _boutonsDestinations.map((map) {
                  final bool estSelectionne = _destinationChoisie == map["nom"];
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: estSelectionne
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.08),
                          foregroundColor: estSelectionne
                              ? const Color(0xFF2980B9)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: estSelectionne ? 2 : 0,
                        ),
                        onPressed: () => setState(() {
                          _destinationChoisie = map["nom"]!;
                        }),
                        child: Text(
                          map["label"]!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // 📇 2. CARTE BLANCHE CONTENANT LES 4 CHAMPS STANDARDS (Train, Rame, Chef, Tel)
            _buildCardContainer([
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildStandardField(
                      controller: _numTrainController,
                      icone: Icons.train,
                      hintText: "N° Train (Saisie libre)",
                      estNumerique: true,
                      lectureSeule: _estEnModeModification,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStandardField(
                      controller: _rameController,
                      icone: Icons.directions_railway,
                      label: "N° Rame",
                      estNumerique: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildStandardField(
                      controller: _nomChefController,
                      icone: Icons.person,
                      label: "Nom Chef",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStandardField(
                      controller: _telephoneController,
                      icone: Icons.phone,
                      label: "N° Téléphone",
                      estNumerique: true,
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 16),
            // 📅 3. SECONDE CARTE BLANCHE CONTENANT LA DATE ET LES HEURES
            _buildCardContainer([
              _buildStandardField(
                controller: _dateController,
                icone: Icons.calendar_today_rounded,
                label: "Date",
                lectureSeule: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStandardField(
                      controller: _departController,
                      icone: Icons.access_time_rounded,
                      label: "Heure Départ",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStandardField(
                      controller: _arriveeController,
                      icone: Icons.update_rounded,
                      label: "Heure Arrivée",
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 24),
            // ⚠️ 4. LE GRAND BLOC ANOMALIES AUTONOME (Dessiné sous les cartes)
            const Text(
              "ANOMALIES AU DÉPART",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            _buildGrandChampAnomalies(controller: _anomaliesController),
            const SizedBox(height: 16),
            // 📢 5. ACTIVATION DU BANDEAU PUBLICITAIRE / INFORMATIF RECONSTITUÉ
            _buildEcranAccueilPublicitaire(),
            const SizedBox(height: 24),
            // 🟩 6. LE BOUTON DE VALIDATION VERT ET ETIRÉ TOUT EN BAS
            ElevatedButton(
              onPressed: _sauvegarderEtBasculerVersAccueil,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: const Text(
                "VALIDER LA MISSION",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
