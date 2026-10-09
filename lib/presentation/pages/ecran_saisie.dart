import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movies_demo/domain/entities/mission.dart';
import 'package:movies_demo/presentation/providers/mission_provider.dart';

import 'ecran_accueil.dart';

class EcranSaisiePremium extends StatefulWidget {
  const EcranSaisiePremium({super.key});

  @override
  State<EcranSaisiePremium> createState() => _EcranSaisiePremiumState();
}

class _EcranSaisiePremiumState extends State<EcranSaisiePremium> {
  final _formKey = GlobalKey<FormState>();
  bool _estEnModeModification = false;
  String _numTrainOrigine = "";

  // Variable d'état de votre croquis d'origine
  String _destinationChoisie = "";

  late TextEditingController _numTrainController;
  late TextEditingController _dateController;
  late TextEditingController _departController;
  late TextEditingController _arriveeController;
  late TextEditingController _nomChefController;
  late TextEditingController _telephoneController;
  late TextEditingController _rameController;

  // 🛡️ RESTAURATION DE LA VARIABLE MANQUANTE : Configuration de vos 4 boutons d'axes ONCF
  final List<Map<String, String>> _boutonsDestinations = [
    {"label": "K", "nom": "KENITRA", "code": "250"},
    {"label": "EJ", "nom": "EL JADIDA", "code": "610"},
    {"label": "S", "nom": "SETTAT", "code": "139"},
    {"label": "A", "nom": "AÉROPORT MED V", "code": "190"},
  ];

  final List<Map<String, dynamic>> _categoriesRames = [
    {
      "categorie": "Série ZM",
      "valeurs": ["2", "16", "18", "24"],
    },
    {
      "categorie": "Série Z2M",
      "valeurs": ["101", "126", "132", "140"],
    },
  ];

  @override
  void initState() {
    super.initState();
    final missionActuelle = context.read<MissionProvider>().missionActuelle;
    _estEnModeModification = missionActuelle != null;

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
    super.dispose();
  }

  void _sauvegarderEtBasculerVersAccueil() async {
    if (_formKey.currentState!.validate() && _destinationChoisie.isNotEmpty) {
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
        anomaliesDepart: const [],
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
          children: <Widget>[
            // 📊 BANDEAU BLEU NUIT DES BOUTONS DE DESTINATION RE-CONSOLIDÉ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                // color: const Color(0xFF113147),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _boutonsDestinations.map<Widget>((map) {
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
                          elevation: estSelectionne ? 3 : 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: estSelectionne
                                  ? Colors.transparent
                                  : Colors.white.withValues(alpha: 0.3),
                              width: 1.2,
                            ),
                          ),
                        ),
                        onPressed: () => setState(() {
                          _destinationChoisie = map["nom"]!;
                        }),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              map["label"]!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: estSelectionne
                                    ? const Color(0xFF27AE60)
                                    : Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Commutation de la machine à états de votre croquis d'origine
            _destinationChoisie.isEmpty
                ? _buildEcranAccueilPublicitaire()
                : _buildFormulaireTechniqueMissions(),
          ],
        ),
      ),
    );
  }

  Widget _buildEcranAccueilPublicitaire() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 40),

          Container(
            width: double.infinity,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              // color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBDC3C7), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/spider.jpg',
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          "ONCF",
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B4F72),
                            letterSpacing: 3,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    color: Colors.grey.withValues(alpha: 0.05),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Center(
                      child: Text(
                        "Espace Commercial",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Container(
              width: double.infinity,
              height: 90,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ESPACE PUBLICITAIRE",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  // SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Text(
                        "Saisissez votre texte publicitaire ici ou les annonces commerciales de la brigade. Ce bloc occupe désormais tout l'espace géométrique inférieur de l'écran de saisie mobile pour une visibilité maximale en cabine.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          height: 1.3,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaireTechniqueMissions() {
    return _buildCardContainer([
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildStandardField(
              controller: _numTrainController,
              label: "N° Train (Saisie libre)",
              lectureSeule: _estEnModeModification,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _buildHybrideRameField()),
        ],
      ),
      const SizedBox(height: 16),
      const Text(
        "BRIGADE TRAIN",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.1,
        ),
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          Expanded(
            child: _buildStandardField(
              controller: _nomChefController,
              label: "Nom Chef",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStandardField(
              controller: _telephoneController,
              label: "N° Téléphone",
              estNumerique: true,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: _sauvegarderEtBasculerVersAccueil,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF27AE60),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "VALIDER LA MISSION",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    ]);
  }

  Widget _buildHybrideRameField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _rameController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Rame",
              contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return "Requis";
              return null;
            },
          ),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton(
            icon: const Icon(
              Icons.arrow_drop_down_circle_rounded,
              color: Color(0xFF2980B9),
              size: 22,
            ),
            dropdownColor: Colors.white,
            items: _categoriesRames.expand<DropdownMenuItem>((cat) {
              return [
                DropdownMenuItem(
                  value: null,
                  enabled: false,
                  child: Text(
                    cat["categorie"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 11,
                    ),
                  ),
                ),
                ...(cat["valeurs"] as List).map((rame) {
                  return DropdownMenuItem(
                    value: rame,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        "Rame $rame",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ];
            }).toList(),
            onChanged: (valeurChoisie) {
              if (valeurChoisie != null) {
                setState(() {
                  _rameController.text = valeurChoisie;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer(List<Widget> enfants) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: enfants,
        ),
      ),
    );
  }

  Widget _buildStandardField({
    required TextEditingController controller,
    required String label,
    bool lectureSeule = false,
    bool estNumerique = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: lectureSeule,
      keyboardType: estNumerique ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        filled: lectureSeule,
        fillColor: lectureSeule ? const Color(0xFFEAECEE) : null,
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return "Champ requis";
        }
        return null;
      },
    );
  }
}
