class Mission {
  // 1. BLOC ADMINISTRATIF (INITIALISATION)
  final String numeroTrain;
  final String date;
  final String heureDepart;
  final String heureArrivee;
  final String gareDepart;
  final String gareArrivee;
  final String nomChefDeTrain;
  final String numeroChefDeTrain; // Ajouté pour l'identification matricule
  final List<String> anomaliesDepart; // Grand espace de texte saisi

  // 2. BLOC DE TOURNÉE (COMPTAGE HONEYWELL)
  final int nombreVoitures;
  final int voyagersPremiereCl;
  final int voyagersSecondeCl;
  final int billetsControles;

  Mission({
    required this.numeroTrain,
    required this.date,
    required this.heureDepart,
    required this.heureArrivee,
    required this.gareDepart,
    required this.gareArrivee,
    required this.nomChefDeTrain,
    required this.numeroChefDeTrain,
    required this.anomaliesDepart,
    this.nombreVoitures = 8,
    required this.voyagersPremiereCl,
    required this.voyagersSecondeCl,
    required this.billetsControles,
  });

  // Getters d'analyse automatique pour le Dashboard
  int get totalVoyageurs => voyagersPremiereCl + voyagersSecondeCl;

  double get pourcentageControle {
    if (totalVoyageurs == 0) return 0.0;
    return (billetsControles / totalVoyageurs) * 100;
  }
}
