import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movies_demo/domain/entities/mission.dart';
import 'package:movies_demo/presentation/providers/mission_provider.dart';

class EcranSaisiePremium extends StatefulWidget {
  const EcranSaisiePremium({super.key});

  @override
  State<EcranSaisiePremium> createState() => _EcranSaisiePremiumState();
}

class _EcranSaisiePremiumState extends State<EcranSaisiePremium> {
  final _formKey = GlobalKey<FormState>();
  bool _estEnModeModification = false;
  String _destinationChoisie = "";

  String _classeRabatSelectionnee = "1ère";
  String _classeKenitraSelectionnee = "1ère";

  final List<String> _classesDisponibles = ["1ère", "2ème"];

  // 🧠 Variables mémoires temporaires étanches par gare et par classe
  int _rabatTemp1ere = 0;
  int _rabatTemp2nde = 0;
  int _kenitraTemp1ere = 0;
  int _kenitraTemp2nde = 0;

  late TextEditingController _numTrainController;
  late TextEditingController _dateController;
  late TextEditingController _departController;
  late TextEditingController _arriveeController;
  late TextEditingController _nomChefController;
  late TextEditingController _telephoneController;
  late TextEditingController _rameController;
  late TextEditingController _anomaliesController;

  late TextEditingController _rabatVoyageursController;
  late TextEditingController _kenitraVoyageursController;
  late TextEditingController _bcGareArriveeController;

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
      text: (missionActuelle == null || missionActuelle.comptageTerminal == 0)
          ? ''
          : "${missionActuelle.comptageTerminal}",
    );

    _rabatVoyageursController = TextEditingController(text: '');
    _kenitraVoyageursController = TextEditingController(text: '');
    _bcGareArriveeController = TextEditingController(text: '');
    _classeRabatSelectionnee = "1ère";
    _classeKenitraSelectionnee = "1ère";

    // 🔄 RESTITUTION INFAILLIBLE DE TOUTES LES VALEURS VIA JSON PAR GARE ELEM
    if (_estEnModeModification && missionActuelle != null) {
      _destinationChoisie = missionActuelle.gareArrivee;
      _bcGareArriveeController.text = missionActuelle.billetsControles == 0
          ? ''
          : "${missionActuelle.billetsControles}";

      if (missionActuelle.typeService.isNotEmpty &&
          missionActuelle.typeService.startsWith("{")) {
        try {
          final Map<String, dynamic> data = jsonDecode(
            missionActuelle.typeService,
          );

          _classeRabatSelectionnee = data["rabat_classe"] ?? "1ère";
          _classeKenitraSelectionnee = data["kenitra_classe"] ?? "1ère";

          _rabatTemp1ere = data["rabat_1"] ?? 0;
          _rabatTemp2nde = data["rabat_2"] ?? 0;
          _kenitraTemp1ere = data["kenitra_1"] ?? 0;
          _kenitraTemp2nde = data["kenitra_2"] ?? 0;

          if (_classeRabatSelectionnee == "1ère") {
            _rabatVoyageursController.text = _rabatTemp1ere == 0
                ? ''
                : '$_rabatTemp1ere';
          } else {
            _rabatVoyageursController.text = _rabatTemp2nde == 0
                ? ''
                : '$_rabatTemp2nde';
          }

          if (_classeKenitraSelectionnee == "1ère") {
            _kenitraVoyageursController.text = _kenitraTemp1ere == 0
                ? ''
                : '$_kenitraTemp1ere';
          } else {
            _kenitraVoyageursController.text = _kenitraTemp2nde == 0
                ? ''
                : '$_kenitraTemp2nde';
          }
        } catch (_) {}
      }
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
    _anomaliesController.dispose();
    _rabatVoyageursController.dispose();
    _kenitraVoyageursController.dispose();
    _bcGareArriveeController.dispose();
    super.dispose();
  }

  void _sauvegarderEtBasculerVersAccueil() async {
    final bool formulaireValide = _formKey.currentState!.validate();
    final bool destinationValide = _destinationChoisie.isNotEmpty;

    if (formulaireValide && destinationValide) {
      final texteAnomalies = _anomaliesController.text.trim();
      final List<String> listeAnomalies = texteAnomalies.isEmpty
          ? const []
          : [texteAnomalies];

      final int valeurRabatEcran =
          int.tryParse(_rabatVoyageursController.text.trim()) ?? 0;
      if (_classeRabatSelectionnee == "1ère") {
        _rabatTemp1ere = valeurRabatEcran;
      } else {
        _rabatTemp2nde = valeurRabatEcran;
      }

      final int valeurKenitraEcran =
          int.tryParse(_kenitraVoyageursController.text.trim()) ?? 0;
      if (_classeKenitraSelectionnee == "1ère") {
        _kenitraTemp1ere = valeurKenitraEcran;
      } else {
        _kenitraTemp2nde = valeurKenitraEcran;
      }

      final int bcBilletsSaisis =
          int.tryParse(_bcGareArriveeController.text.trim()) ?? 0;
      final int rameSaisie = int.tryParse(_rameController.text.trim()) ?? 0;

      // 💾 ENCODAGE JSON TOTALEMENT ÉTANCHE SANS AUCUN CONFLIT POSSIBLE
      final Map<String, dynamic> mappingJson = {
        "rabat_classe": _classeRabatSelectionnee,
        "kenitra_classe": _classeKenitraSelectionnee,
        "rabat_1": _rabatTemp1ere,
        "rabat_2": _rabatTemp2nde,
        "kenitra_1": _kenitraTemp1ere,
        "kenitra_2": _kenitraTemp2nde,
      };

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
        anomaliesDepart: listeAnomalies,
        billetsControles: bcBilletsSaisis,
        voyageursPremiereCl: _kenitraTemp1ere,
        voyageursSecondeCl: _kenitraTemp2nde,
        comptageRabat: _classeRabatSelectionnee == "1ère"
            ? _rabatTemp1ere
            : _rabatTemp2nde,
        comptageTerminal: rameSaisie,
        typeService: jsonEncode(mappingJson),
      );

      final missionProvider = Provider.of<MissionProvider>(
        context,
        listen: false,
      );

      if (_estEnModeModification) {
        await missionProvider.mettreAJourMission(nouvelleMission);
      } else {
        await missionProvider.ajouterNouvelleMission(nouvelleMission);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez valider le formulaire et choisir une destination (Axe).",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F4),
      appBar: AppBar(
        title: Text(
          _estEnModeModification
              ? "Détails Train ${_numTrainController.text}"
              : "Bordereau de Saisie",
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- GARE 1 : RABAT AGDAL ---
                      const Text(
                        "RABAT AGDAL",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              initialValue: _classeRabatSelectionnee,
                              decoration: const InputDecoration(
                                labelText: "Classe",
                                border: OutlineInputBorder(),
                              ),
                              items: _classesDisponibles
                                  .map(
                                    (String value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  final int valeurTappee =
                                      int.tryParse(
                                        _rabatVoyageursController.text.trim(),
                                      ) ??
                                      0;
                                  if (_classeRabatSelectionnee == "1ère") {
                                    _rabatTemp1ere = valeurTappee;
                                  } else {
                                    _rabatTemp2nde = valeurTappee;
                                  }
                                  _classeRabatSelectionnee = newValue!;
                                  _rabatVoyageursController.text =
                                      _classeRabatSelectionnee == "1ère"
                                      ? (_rabatTemp1ere == 0
                                            ? ''
                                            : '$_rabatTemp1ere')
                                      : (_rabatTemp2nde == 0
                                            ? ''
                                            : '$_rabatTemp2nde');
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              controller: _rabatVoyageursController,
                              decoration: const InputDecoration(
                                labelText: "Saisir valeur cl",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? "Requis"
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      const Divider(),
                      const SizedBox(height: 8.0),
                      // --- GARE 2 : KÉNITRA ---
                      const Text(
                        "KÉNITRA",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField(
                              initialValue: _classeKenitraSelectionnee,
                              decoration: const InputDecoration(
                                labelText: "Classe",
                                border: OutlineInputBorder(),
                              ),
                              items: _classesDisponibles
                                  .map(
                                    (String value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  final int valeurTappee =
                                      int.tryParse(
                                        _kenitraVoyageursController.text.trim(),
                                      ) ??
                                      0;
                                  if (_classeKenitraSelectionnee == "1ère") {
                                    _kenitraTemp1ere = valeurTappee;
                                  } else {
                                    _kenitraTemp2nde = valeurTappee;
                                  }
                                  _classeKenitraSelectionnee = newValue!;
                                  _kenitraVoyageursController.text =
                                      _classeKenitraSelectionnee == "1ère"
                                      ? (_kenitraTemp1ere == 0
                                            ? ''
                                            : '$_kenitraTemp1ere')
                                      : (_kenitraTemp2nde == 0
                                            ? ''
                                            : '$_kenitraTemp2nde');
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              controller: _kenitraVoyageursController,
                              decoration: const InputDecoration(
                                labelText: "Saisir valeur cl",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? "Requis"
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Card(
                elevation: 3,
                color: Colors.amber.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: const BorderSide(color: Colors.amber, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _bcGareArriveeController,
                    decoration: const InputDecoration(
                      labelText: "BC (Nombre de billets contrôlés)",
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: Icon(
                        Icons.confirmation_number,
                        color: Colors.amber,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? "BC obligatoire"
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _numTrainController,
                      decoration: const InputDecoration(
                        labelText: "N° Train",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: TextFormField(
                      controller: _rameController,
                      decoration: const InputDecoration(
                        labelText: "N° Rame",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              const Text(
                "Axe / Destination finale :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _boutonsDestinations.map((btn) {
                  final bool estSelectionne = _destinationChoisie == btn["nom"];
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: estSelectionne
                          ? Colors.blue.shade800
                          : Colors.grey.shade300,
                      foregroundColor: estSelectionne
                          ? Colors.white
                          : Colors.black87,
                    ),
                    onPressed: () =>
                        setState(() => _destinationChoisie = btn["nom"]!),
                    child: Text(btn["label"]!),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28.0),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: const Color(0xFFFFB300),
                  foregroundColor: Colors.black87,
                ),
                icon: const Icon(Icons.edit),
                label: Text(
                  _estEnModeModification
                      ? "CONFIRMER LA MODIFICATION"
                      : "ENREGISTRER LE TRAIN",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                onPressed: _sauvegarderEtBasculerVersAccueil,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
