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
  String _numTrainOrigine = "";

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

      // On enregistre d'abord la valeur actuellement écrite à l'écran dans sa bonne case temporaire
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

      // 💾 Encodage JSON étanche
      final Map<String, dynamic> mappingJson = {
        "rabat_classe": _classeRabatSelectionnee,
        "kenitra_classe": _classeKenitraSelectionnee,
        "rabat_1": _rabatTemp1ere,
        "rabat_2": _rabatTemp2nde,
        "kenitra_1": _kenitraTemp1ere,
        "kenitra_2": _kenitraTemp2nde,
      };

      final String trainSaisiActuel = _numTrainController.text.trim().isEmpty
          ? "0"
          : _numTrainController.text.trim();

      // 🛠️ LOGIQUE SÉCURISÉE ANTI-DOUBLON :
      // Si on est en modification et que le numéro de train a été changé,
      // on supprime d'abord l'ancien numéro de la base pour éviter les doublons fantômes.
      final missionProvider = Provider.of<MissionProvider>(
        context,
        listen: false,
      );
      if (_estEnModeModification &&
          _numTrainOrigine.isNotEmpty &&
          _numTrainOrigine != trainSaisiActuel) {
        await missionProvider.supprimerMission(_numTrainOrigine);
      }

      final nouvelleMission = Mission(
        numeroTrain: trainSaisiActuel,
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

      // Enregistrement unifié (le Repository appliquera le ConflictAlgorithm.replace sur le numéro de train)
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
      backgroundColor: const Color(
        0xFF2980B9,
      ), // 🔥 Arrière-plan bleu identique à l'écran d'accueil
      appBar: AppBar(
        title: Text(
          _estEnModeModification
              ? "Modification Mission"
              : "Bordereau de Saisie",
        ),
        backgroundColor: const Color(0xFF1976D2), // Bleu ONCF de la barre
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 24.0,
            ),
            children: [
              // =========================================================================
              // 📦 CONTAINER 1 : IDENTIFICATION TECHNIQUE & BRIGADE DE BORD
              // =========================================================================
              // =========================================================================
              // 📦 CONTAINER 1 : IDENTIFICATION TECHNIQUE, HORAIRES & BRIGADE DE BORD
              // =========================================================================
              Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  // Coins arrondis uniquement sur le bas pour une transition fluide
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24.0),
                    bottomRight: Radius.circular(24.0),
                  ),
                  border: Border.all(color: const Color(0xFFE5E8E8), width: 1),
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
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        "IDENTIFICATION DU TRAIN & BRIGADE",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    // --- LIGNE 1 : N° TRAIN & N° RAME ---
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _numTrainController,
                            decoration: const InputDecoration(
                              labelText: "N° Train",
                              prefixIcon: Icon(
                                Icons.train,
                                color: Color(0xFF1976D2),
                                size: 20,
                              ),
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
                              prefixIcon: Icon(
                                Icons.confirmation_number_outlined,
                                color: Color(0xFF1976D2),
                                size: 20,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14.0),

                    // --- ⏰ LIGNE 2 : REINTEGRATION DES HORAIRES (DEPART & ARRIVÉE) ---
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _departController, // Contrôleur d'origine réactivé
                            decoration: const InputDecoration(
                              labelText: "Heure Départ",
                              prefixIcon: Icon(
                                Icons.access_time_filled,
                                color: Color(0xFF1976D2),
                                size: 20,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.datetime,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: TextFormField(
                            controller: _arriveeController, // Contrôleur d'origine réactivé
                            decoration: const InputDecoration(
                              labelText: "Heure Arrivée",
                              prefixIcon: Icon(
                                Icons.access_time,
                                color: Color(0xFF1976D2),
                                size: 20,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.datetime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14.0),

                    // --- LIGNE 3 : BRIGADE (NOM & TELEPHONE) ---
                    TextFormField(
                      controller: _nomChefController,
                      decoration: const InputDecoration(
                        labelText: "Nom Chef de Train",
                        prefixIcon: Icon(
                          Icons.person,
                          color: Color(0xFF1976D2),
                          size: 20,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 14.0),
                    TextFormField(
                      controller: _telephoneController,
                      decoration: const InputDecoration(
                        labelText: "Téléphone Brigade",
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Color(0xFF1976D2),
                          size: 20,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),

              // =========================================================================
              // 📦 CONTAINER 2 (MILIEU) : INCIDENTS & ANOMALIES DE ROUTE
              // =========================================================================
              const Padding(
                padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  "SUIVI DES INCIDENTS & ANOMALIES",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: const Color(0xFFE5E8E8), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _anomaliesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Saisir les anomalies de route...",
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 22,
                      ),
                    ),
                    border: OutlineInputBorder(),
                    hintText: "Ex: Retard signalisation, problème de rame...",
                  ),
                ),
              ),

              // =========================================================================
              // 📦 CONTAINER 3 : EXPLOITATION, COMPTAGES & BILLET (BC)
              // =========================================================================
              const Padding(
                padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  "BILAN DES VOYAGEURS ET DES CONTROLES (BC)",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 24.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: const Color(0xFFE5E8E8), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- GARE 1 : RABAT AGDAL ---
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF1976D2),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "RABAT AGDAL",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
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
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                            ),
                            items: _classesDisponibles
                                .map(
                                  (String val) => DropdownMenuItem(
                                    value: val,
                                    child: Text(
                                      val,
                                      style: const TextStyle(fontSize: 13),
                                    ),
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
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
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
                    const SizedBox(height: 10.0),
                    // --- GARE 2 : KÉNITRA ---
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "KÉNITRA",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
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
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
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
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? "Requis"
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    // --- CHAMP BC AUTONOME ---
                    TextFormField(
                      controller: _bcGareArriveeController,
                      decoration: InputDecoration(
                        labelText: "BC (Nombre de billets contrôlés)",
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7D6608),
                        ),
                        border: const OutlineInputBorder(),
                        fillColor: const Color(0xFFFFC400)
                            .withValues(alpha: 0.05),
                        filled: true,
                        prefixIcon: const Icon(
                          Icons.confirmation_number,
                          color: Color(0xFFFFC400),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? "BC obligatoire"
                          : null,
                    ),
                  ],
                ),
              ),
              // --- SÉLECTION DE L'AXE ---
              const Text(
                "Axe / Destination finale :",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _boutonsDestinations.map((btn) {
                  final bool estSelectionne = _destinationChoisie == btn["nom"];
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: estSelectionne
                          ? const Color(0xFF1976D2)
                          : Colors.white24,
                      foregroundColor: estSelectionne
                          ? Colors.white
                          : Colors.white,
                      disabledForegroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () =>
                        setState(() => _destinationChoisie = btn["nom"]!),
                    child: Text(
                      btn["label"]!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: estSelectionne ? Colors.white : Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32.0),
              // --- BOUTON ENREGISTRER ---
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: const Color(
                    0xFFFFB300,
                  ), // Bouton jaune de validation
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 3,
                ),
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.black87,
                ),
                label: Text(
                  _estEnModeModification
                      ? "CONFIRMER LA MODIFICATION"
                      : "ENREGISTRER LE TRAIN",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.3,
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
