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
  String _numTrainOrigine = "";
  String _destinationChoisie = "";
  String _gareComptageSelectionnee =
      "KENITRA"; // Valeur par défaut au démarrage
  String _confortSelectionne = "Premiere Classe";
  // Valeur par défaut pour le Confort

  late TextEditingController _numTrainController;
  late TextEditingController _dateController;
  late TextEditingController _departController;
  late TextEditingController _arriveeController;
  late TextEditingController _nomChefController;
  late TextEditingController _telephoneController;
  late TextEditingController _rameController;
  late TextEditingController _anomaliesController;
  // 🔥 LES NOUVEAUX CONTRÔLEURS DE COMPTAGE À AJOUTER ICI :
  late TextEditingController _billetsController;
  // 🟩 REMPLACEZ PAR CE NOM PROPRE :
  late TextEditingController _premiereClasseController;

  late TextEditingController _rabatController;
  late TextEditingController _terminalController;
  // 🔥 DECIARATION DU DICTIONNAIRE GLOBAL AU BON ENDROIT :
  final Map<String, String> _codesGaresONCF = {
    "KENITRA": "250",
    "CASA-PORT": "100",
    "RABAT-VILLE": "320",
    "SETTAT": "139",
  };

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
    // ... Vos initialisations de contrôleurs existants restent identiques ...
    _telephoneController = TextEditingController(
      text: missionActuelle?.numeroChefDeTrain ?? '',
    );
    _rameController = TextEditingController(
      text: (missionActuelle == null || missionActuelle.voyageursSecondeCl == 0)
          ? ''
          : "${missionActuelle.voyageursSecondeCl}",
    );

    // 🔥 INITIALISATION DES NOUVEAUX CONTRÔLEURS DE COMPTAGE :
    _billetsController = TextEditingController(
      text: (missionActuelle == null || missionActuelle.billetsControles == 0)
          ? ''
          : "${missionActuelle.billetsControles}",
    );
    _premiereClasseController = TextEditingController(
      text:
          (missionActuelle == null || missionActuelle.voyageursPremiereCl == 0)
          ? ''
          : "${missionActuelle.voyageursPremiereCl}",
    );
    _rabatController = TextEditingController(
      text: (missionActuelle == null || missionActuelle.comptageRabat == 0)
          ? ''
          : "${missionActuelle.comptageRabat}",
    );
    _terminalController = TextEditingController(
      text: (missionActuelle == null || missionActuelle.comptageTerminal == 0)
          ? ''
          : "${missionActuelle.comptageTerminal}",
    );

    if (_estEnModeModification) {
      _numTrainOrigine = missionActuelle!.numeroTrain;
      _destinationChoisie = missionActuelle.gareArrivee;
    }
  }

  @override
  void dispose() {
    // Libération des contrôleurs de base
    _numTrainController.dispose();
    _dateController.dispose();
    _departController.dispose();
    _arriveeController.dispose();
    _nomChefController.dispose();
    _telephoneController.dispose();
    _rameController.dispose();
    _anomaliesController.dispose();

    // Libération des contrôleurs de comptage
    _billetsController.dispose();
    _premiereClasseController.dispose();
    _rabatController.dispose();
    _terminalController.dispose();

    // Clôture native obligatoire
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

      // 🟩 ADAPTATION ET LIAISON DIRECTE AVEC VOTRE MODÈLE MISSION EXISTING
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

        // 📊 Liaison de vos nouveaux champs de comptage Honeywell :
        billetsControles: int.tryParse(_billetsController.text.trim()) ?? 0,
        voyageursSecondeCl:
            int.tryParse(_rameController.text.trim()) ??
            0, // Valeur estimée mappée sur la 2nde Classe
        voyageursPremiereCl:
            int.tryParse(_premiereClasseController.text.trim()) ??
            0, // 0 par défaut ou lié si réactivé
        comptageRabat: int.tryParse(_rabatController.text.trim()) ?? 0,
        comptageTerminal: int.tryParse(_terminalController.text.trim()) ?? 0,

        // On utilise ce champ textuel libre pour conserver la trace de la gare sélectionnée dans SQLite
        typeService:
            "GARE: $_gareComptageSelectionnee | CONFORT: $_confortSelectionne",
      );

      final missionProvider = Provider.of<MissionProvider>(
        context,
        listen: false,
      );

      if (_estEnModeModification &&
          _numTrainOrigine != nouvelleMission.numeroTrain) {
        await missionProvider.supprimerMission(_numTrainOrigine);
        if (!mounted) return; // Garde de sécurité contre l'async gap validé
      }

      // Enregistrement dans SQLite via le Provider
      await missionProvider.enregistrerMission(nouvelleMission);

      if (!mounted) return;

      // 🏁 Fermeture fluide du formulaire vers l'accueil (Zéro doublon visuel)
      Navigator.of(context).pop();
    }
  }

  // 🎨 FONCTION DE GRAPHISME : Les champs standards équipés de leur LIGNE JAUNE
  Widget _buildStandardField({
    required TextEditingController controller,
    required IconData icone,
    String? label,
    String? hintText,
    bool lectureSeule = false,
    bool estNumerique = false,
    ValueChanged<String>?
    onChanged, // 🟩 AJOUTÉ : Permet de capter les changements de texte
  }) {
    return TextFormField(
      controller: controller,
      readOnly: lectureSeule,
      onChanged: onChanged, // 🟩 CONNECTÉ : Le champ écoute désormais le doigt de l'agent
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

        // Lignes Jaunes ONCF
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFFC400), width: 2.0),
        ),
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

  Widget _buildEcranAccueilPublicitaire() {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0));
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

            // 🟩 ET METTEZ À LA PLACE VOTRE COUPLAGE EXACT DOUBLE COLONNE :
            _buildCardContainer([
              const Text(
                "DONNÉES DE COMPTAGE & CONTRÔLES",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // 🟩 ROW PRINCIPALE AVEC SÉCURITÉ VERTICALE ALIGNÉE SUR LE HAUT
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Aligne le haut des colonnes pour éviter les décalages
                children: [
                  // ==========================================
                  // ⬅️ COLONNE 1 : À GAUCHE (CODE + BILLETS CONTRÔLÉS)
                  // ==========================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. L'affichage du Code de gare automatique (Hauteur calée sur 52px pour la symétrie)
                        Container(
                          width: double.infinity,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFFC400),
                              width: 2.0,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Code",
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                _codesGaresONCF[_gareComptageSelectionnee] ??
                                    "000",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2C3E50),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 2. Saisie du nombre de Billets Contrôlés
                        _buildStandardField(
                          controller: _billetsController,
                          icone: Icons.confirmation_number_rounded,
                          label: "Billets Contr.", // Libellé légèrement raccourci pour éviter l'overflow de texte
                          estNumerique: true,
                          onChanged: (val) => setState(() {}),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ), // Espace de séparation central optimisé
                  // ==========================================
                  // ➡️ COLONNE 2 : À DROITE (GARES + CLASSES + ESTIMATION)
                  // ==========================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Menu déroulant pour la Gare (Hauteur interne optimisée via contentPadding)
                        DropdownButtonFormField<String>(
                          value: _gareComptageSelectionnee,
                          dropdownColor: Colors.white,
                          isExpanded: true, // 🔥 FORCE LE TEXTE À RESTER DANS LES LIMITES DE LA COLONNE
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.orange,
                            size: 22,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF2C3E50),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: "Gare Départ/Arrivée",
                            labelStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ), // Padding réduit anti-overflow
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFFFC400),
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFFFC400),
                                width: 3.0,
                              ),
                            ),
                          ),
                          items: _codesGaresONCF.keys.map((String gare) {
                            return DropdownMenuItem<String>(
                              value: gare,
                              child: Text(gare, overflow: TextOverflow.ellipsis), // Coupe proprement si le nom de la gare est trop long
                            );
                          }).toList(),
                          onChanged: (String? nouvelleGare) {
                            if (nouvelleGare != null) {
                              setState(() {
                                _gareComptageSelectionnee = nouvelleGare;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // 2. Menu déroulant pour le Confort (1ère / 2nde Classe)
                        DropdownButtonFormField<String>(
                          value: _confortSelectionne,
                          dropdownColor: Colors.white,
                          isExpanded: true, // 🔥 Évite l'overflow horizontal à l'ouverture
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.orange,
                            size: 22,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF2C3E50),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: "Classe Confort",
                            labelStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFFFC400),
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFFFC400),
                                width: 3.0,
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem<String>(
                              value: "Premiere Classe",
                              child: Text(
                                "1ère Classe",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: "Deuxieme Classe",
                              child: Text(
                                "2nde Classe",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          onChanged: (String? nouvelleValeurConfort) {
                            if (nouvelleValeurConfort != null) {
                              setState(() {
                                _confortSelectionne = nouvelleValeurConfort;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // 3. Saisie de la Valeur Estimée
                        _buildStandardField(
                          controller: _rameController,
                          icone: Icons.edit_attributes_rounded,
                          label: "Valeur estimée",
                          hintText: "Estimation...",
                          estNumerique: true,
                          onChanged: (val) => setState(() {}),
                        ),
                      ],
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
