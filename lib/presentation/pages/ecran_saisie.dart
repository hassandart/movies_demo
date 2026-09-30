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
  late TextEditingController _numTrainController;
  late TextEditingController _chefTrainController;
  late TextEditingController _departController;
  late TextEditingController _arriveeController;
  final _anomalieController = TextEditingController();
  List<String> _listeAnomalies = [];

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    final missionActuelle = context.read<MissionProvider>().missionActuelle;
    _numTrainController = TextEditingController(
      text: missionActuelle?.numeroTrain ?? '',
    );
    _chefTrainController = TextEditingController(
      text: missionActuelle?.nomChefDeTrain ?? '',
    );
    _departController = TextEditingController(
      text: missionActuelle?.heureDepart ?? '',
    );
    _arriveeController = TextEditingController(
      text: missionActuelle?.heureArrivee ?? '',
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

  @override
  void dispose() {
    _numTrainController.dispose();
    _chefTrainController.dispose();
    _departController.dispose();
    _arriveeController.dispose();
    _anomalieController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _sauvegarderMission() {
    if (_formKey.currentState!.validate()) {
      final nouvelleMission = Mission(
        numeroTrain: _numTrainController.text.trim(),
        nomChefDeTrain: _chefTrainController.text.trim(),
        heureDepart: _departController.text.trim(),
        heureArrivee: _arriveeController.text.trim(),
        anomaliesDepart: _listeAnomalies,
      );

      context.read<MissionProvider>().enregistrerMission(nouvelleMission);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mission activée et enregistrée !"),
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
      backgroundColor: const Color(0xFF2C2670),
      body: Stack(
        children: [
          // ANIMATION 1/3 DU HAUT
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: tiersHauteur,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2C2670), Color(0xFF4A3F9A)],
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
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                            ),
                            child: const Icon(
                              Icons.wifi_protected_setup_rounded,
                              size: 45,
                              color: Colors.orange,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Synchronisation Rame",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
          // FORMULAIRE 2/3 DU BAS
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
                        "IDENTIFICATION DU TRAIN",
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
                            _buildPremiumTextField(
                              controller: _numTrainController,
                              label: "Numéro de Train",
                              hint: "Ex: TGV 8405",
                              icon: Icons.train_rounded,
                            ),
                            const SizedBox(height: 20),
                            _buildPremiumTextField(
                              controller: _chefTrainController,
                              label: "Chef de Train",
                              hint: "Nom du responsable",
                              icon: Icons.person_pin_rounded,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPremiumTextField(
                                    controller: _departController,
                                    label: "Départ",
                                    hint: "08:14",
                                    icon: Icons.access_time_filled_rounded,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildPremiumTextField(
                                    controller: _arriveeController,
                                    label: "Arrivée",
                                    hint: "11:32",
                                    icon: Icons.flag_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "ANOMALIES ET ALERTES",
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
                                    controller: _anomalieController,
                                    decoration: InputDecoration(
                                      hintText:
                                          "Signaler un problème technique...",
                                      hintStyle: const TextStyle(
                                        color: Colors.black26,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF8F9FD),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    if (_anomalieController.text
                                        .trim()
                                        .isNotEmpty) {
                                      setState(() {
                                        _listeAnomalies.add(
                                          _anomalieController.text.trim(),
                                        );
                                        _anomalieController.clear();
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE67E22),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_listeAnomalies.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _listeAnomalies.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF4EB),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFFFD5B4),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          color: Color(0xFFE67E22),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _listeAnomalies[index],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF7F4512),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      GestureDetector(
                        onTap: _sauvegarderMission,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2C2670), Color(0xFF4A3F9A)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              "Valider & Enregistrer",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2670),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.black26,
              fontWeight: FontWeight.normal,
            ),
            prefixIcon: Icon(icon, color: const Color(0xFFE67E22), size: 22),
            filled: true,
            fillColor: const Color(0xFFF8F9FD),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFEAEBFF),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF2C2670), width: 2),
            ),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? "Champ obligatoire" : null,
        ),
      ],
    );
  }

  BoxDecoration _customBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
