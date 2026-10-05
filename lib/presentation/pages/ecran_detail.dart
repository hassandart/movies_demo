import 'package:flutter/material.dart';
import 'package:movies_demo/domain/entities/mission.dart';

class EcranDetailMission extends StatelessWidget {
  final Mission mission;

  const EcranDetailMission({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    final int nbAnomalies = mission.anomaliesDepart.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Fiche de la Mission",
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARTE DU TRAIN CONNECTÉE À SQFLITE
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2980B9), Color(0xFF3498DB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.train_rounded,
                        color: Colors.orange,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        mission.numeroTrain,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white30, height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "DÉPART",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mission.gareDepart.isEmpty
                                ? "Inconnue"
                                : mission.gareDepart,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white54,
                        size: 28,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "ARRIVÉE",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mission.gareArrivee.isEmpty
                                ? "Inconnue"
                                : mission.gareArrivee,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ÉQUIPE DE BORD
            const Text(
              "ÉQUIPE DE BORD",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF2980B9),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  mission.nomChefDeTrain,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                subtitle: const Text("Chef de train responsable"),
              ),
            ),
            const SizedBox(height: 30),

            // LISTE DES ANOMALIES
            Text(
              "ANOMALIES CONSTATÉES ($nbAnomalies)",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            if (nbAnomalies == 0)
              const Card(
                elevation: 0,
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text(
                    "Rien à signaler",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "La rame ne présente aucun problème technique.",
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: nbAnomalies,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: const Color(0xFFFFF4EB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFFFD5B4)),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                      ),
                      title: Text(
                        mission.anomaliesDepart[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7F4512),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
