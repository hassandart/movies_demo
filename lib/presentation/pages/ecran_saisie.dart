import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movies_demo/domain/entities/mission.dart';
import 'package:movies_demo/presentation/providers/mission_provider.dart';

class EcranSaisiePremium extends StatefulWidget {
  const EcranSaisiePremium({super.key});

  @override
  State<EcranSaisiePremium> createState() => _EcranSaisiePremiumState();
}

class _EcranSaisiePremiumState extends State<EcranSaisiePremium>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _estEnModeModification = false;
  String _numTrainOrigine = "";

  late TextEditingController _numTrainController;
  late TextEditingController _dateController;
  late TextEditingController _departController;
  late TextEditingController _arriveeController;
  late TextEditingController _nomChefController;
  late TextEditingController _numChefController;

  late TextEditingController _codeGareController;
  late TextEditingController _valeurSystemeController;
  late TextEditingController _valeurEstimeeController;

  final String _gareDepartFixe = "CASA-PORT";
  String _gareArriveeSelectionnee = "KENITRA";

  final Map<String, Map<String, String>> _donneesLignes = {
    "KENITRA": {"code": "250", "duree": "01:20", "train": "16"},
    "EL JADIDA": {"code": "310", "duree": "01:30", "train": "601"},
    "SETTAT": {"code": "420", "duree": "01:10", "train": "905"},
  };

  final _anomaliesTexteController = TextEditingController();
  List<String> _listeAnomalies = [];

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    final missionActuelle = context.read<MissionProvider>().missionActuelle;

    _estEnModeModification = missionActuelle != null;
    if (_estEnModeModification) {
      _numTrainOrigine = missionActuelle!.numeroTrain;
      _gareArriveeSelectionnee =
          _donneesLignes.containsKey(missionActuelle.gareArrivee)
          ? missionActuelle.gareArrivee
          : "KENITRA";
    }

    String trainDefaut = _donneesLignes[_gareArriveeSelectionnee]!["train"]!;
    String codeDefaut = _donneesLignes[_gareArriveeSelectionnee]!["code"]!;

    final DateTime maintenant = DateTime.now();
    final String dateFormatee =
        "${maintenant.day.toString().padLeft(2, '0')}/${maintenant.month.toString().padLeft(2, '0')}/${maintenant.year}";

    _numTrainController = TextEditingController(
      text: missionActuelle?.numeroTrain ?? trainDefaut,
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
      text: missionActuelle?.nomChefDeTrain ?? 'Hassan',
    );
    _numChefController = TextEditingController(
      text: missionActuelle?.numeroChefDeTrain ?? 'CH-9482',
    );

    _codeGareController = TextEditingController(
      text: missionActuelle != null ? "250" : codeDefaut,
    );
    _valeurSystemeController = TextEditingController(
      text: missionActuelle != null
          ? "${missionActuelle.billetsControles}"
          : '419',
    );
    _valeurEstimeeController = TextEditingController(
      text: missionActuelle != null
          ? "${missionActuelle.totalVoyageurs}"
          : '306',
    );

    _listeAnomalies = List.from(missionActuelle?.anomaliesDepart ?? []);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _mettreAJourDonneesLigne(String destination) {
    setState(() {
      _gareArriveeSelectionnee = destination;
      _codeGareController.text = _donneesLignes[destination]!["code"]!;
      _numTrainController.text = _donneesLignes[destination]!["train"]!;
      if (destination == "KENITRA") {
        _arriveeController.text = "12:25";
      } else if (destination == "EL JADIDA") {
        _arriveeController.text = "12:35";
      } else {
        _arriveeController.text = "12:15";
      }
    });
  }

  @override
  void dispose() {
    _numTrainController.dispose();
    _dateController.dispose();
    _departController.dispose();
    _arriveeController.dispose();
    _nomChefController.dispose();
    _numChefController.dispose();
    _codeGareController.dispose();
    _valeurSystemeController.dispose();
    _valeurEstimeeController.dispose();
    _anomaliesTexteController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _sauvegarderMission() async {
    if (_formKey.currentState!.validate()) {
      int valSysteme = int.tryParse(_valeurSystemeController.text.trim()) ?? 0;
      int valEstimee = int.tryParse(_valeurEstimeeController.text.trim()) ?? 0;

      final nouvelleMission = Mission(
        numeroTrain: _numTrainController.text.trim(),
        date: _dateController.text.trim(),
        heureDepart: _departController.text.trim(),
        heureArrivee: _arriveeController.text.trim(),
        gareDepart: _gareDepartFixe,
        gareArrivee: _gareArriveeSelectionnee,
        nomChefDeTrain: _nomChefController.text.trim(),
        numeroChefDeTrain: _numChefController.text.trim(),
        anomaliesDepart: _listeAnomalies,
        voyagersPremiereCl: valEstimee,
        voyagersSecondeCl: 0,
        billetsControles: valSysteme,
      );

      // 🛡️ ANTI-CRASH : Ajout explicite du type <MissionProvider>
      final missionProvider = context.read<MissionProvider>();
      if (_estEnModeModification &&
          _numTrainOrigine != nouvelleMission.numeroTrain) {
        await missionProvider.supprimerMission(_numTrainOrigine);
      }
      await missionProvider.enregistrerMission(nouvelleMission);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Données enregistrées !"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double hauteurEcran = MediaQuery.of(context).size.height;
    final double tiersHauteur = hauteurEcran * 1 / 3;

    return Scaffold(
      backgroundColor: const Color(0xFF2980B9),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: tiersHauteur,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2980B9), Color(0xFF3498DB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.white12,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.train_rounded,
                              size: 45,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _estEnModeModification
                          ? "MODIFICATION DES LIENS AXES"
                          : "OUVERTURE DE SERVICE LIGNES",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: tiersHauteur - 20,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      top: 30,
                      left: 20,
                      right: 20,
                      bottom: 40,
                    ),
                    children: [
                      const Text(
                        "1. COMPOSANTE INITIALISATION ADMINISTRATIVE",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: _customBoxDecoration(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStandardField(
                                    controller: _numTrainController,
                                    label: "N° Train",
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStandardField(
                                    controller: _dateController,
                                    label: "Date",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStandardField(
                                    controller: _departController,
                                    label: "H. Départ",
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStandardField(
                                    controller: _arriveeController,
                                    label: "H. Arrivée",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildStandardField(
                              controller: _nomChefController,
                              label: "Nom Chef de Train",
                            ),
                            const SizedBox(height: 16),
                            _buildStandardField(
                              controller: _numChefController,
                              label: "N° Matricule Chef",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "2. SPACES TEXTE ANOMALIES DE DÉPART",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: _customBoxDecoration(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _anomaliesTexteController,
                                    minLines: 2,
                                    maxLines: 4,
                                    keyboardType: TextInputType.multiline,
                                    decoration: InputDecoration(
                                      hintText:
                                          "Saisir une anomalie technique...",
                                      filled: true,
                                      fillColor: const Color(0xFFF8F9FD),
                                      contentPadding: const EdgeInsets.all(12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton.filled(
                                  onPressed: () {
                                    if (_anomaliesTexteController.text
                                        .trim()
                                        .isNotEmpty) {
                                      setState(() {
                                        _listeAnomalies.add(
                                          _anomaliesTexteController.text.trim(),
                                        );
                                        _anomaliesTexteController.clear();
                                      });
                                    }
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFFE67E22),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            if (_listeAnomalies.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _listeAnomalies.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF4EB),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "• ${_listeAnomalies[index]}",
                                            style: const TextStyle(
                                              color: Color(0xFF7F4512),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => setState(
                                              () => _listeAnomalies.removeAt(
                                                index,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "3. SÉLECTION ET COMPTAGE AXE RÉGIONAL TNR",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: _customBoxDecoration(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStaticField(
                                    label: "Gare Départ",
                                    valeur: _gareDepartFixe,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTypedDropdown(
                                    label: "Axe / Destination",
                                    valeur: _gareArriveeSelectionnee,
                                    items: _donneesLignes.keys.toList(),
                                    onChanged: (val) =>
                                        _mettreAJourDonneesLigne(val!),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildHoneywellInputField(
                                    controller: _codeGareController,
                                    label: "Code",
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildHoneywellInputField(
                                    controller: _valeurSystemeController,
                                    label: "Valeur système",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildHoneywellInputField(
                              controller: _valeurEstimeeController,
                              label: "Valeur estimée (Total Passagers)",
                            ),
                            const SizedBox(height: 24),
                            if (!_estEnModeModification)
                              ElevatedButton(
                                onPressed: _sauvegarderMission,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00AA00),
                                  minimumSize: const Size(double.infinity, 52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "VALIDER LA TOURNÉE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _sauvegarderMission,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00AA00),
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "MODIFIER LA TOURNÉE",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      if (_numTrainOrigine.isNotEmpty) {
                                        final navigator = Navigator.of(context);
                                        final scaffoldMessenger =
                                            ScaffoldMessenger.of(context);

                                        // 🛡️ SÉCURISATION DU CRASH : Le type <MissionProvider> est maintenant explicitement déclaré !
                                        final missionProvider = context
                                            .read<MissionProvider>();

                                        await missionProvider.supprimerMission(
                                          _numTrainOrigine,
                                        );
                                        if (!mounted) return;
                                        scaffoldMessenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Mission supprimée !",
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        navigator.pop();
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(
                                        double.infinity,
                                        48,
                                      ),
                                      side: const BorderSide(
                                        color: Colors.red,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.delete_forever_rounded,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      "SUPPRIMER LA MISSION",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardField({
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FD),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEAEBFF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF2980B9),
                width: 1.5,
              ),
            ),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? "Requis" : null,
        ),
      ],
    );
  }

  Widget _buildHoneywellInputField({
    required TextEditingController controller,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: Color(0xFF2C3E50),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.orange, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildStaticField({required String label, required String valeur}) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        filled: true,
        fillColor: const Color(0xFFEEEEEE),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        valeur,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildTypedDropdown({
    required String label,
    required String valeur,
    required List<String>
    items, // On confirme bien à Dart qu'il s'agit de Strings
    required void Function(String?) onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(valeur) ? valeur : items.first,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
          onChanged: onChanged,
          // La fonction d'itération .map prend des données dynamiques et les traite de façon propre
          items: items.map<DropdownMenuItem<String>>((dynamic value) {
            final String valueString = value.toString();
            return DropdownMenuItem<String>(
              value: valueString,
              child: Text(
                valueString,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  BoxDecoration _customBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
