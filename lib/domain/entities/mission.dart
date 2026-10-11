class Mission {
  // 🚆 Identification du Train
  final String numeroTrain;
  final String date;
  final String heureDepart;
  final String heureArrivee;

  // 🗺️ Trajet (Axe ONCF)
  final String gareDepart;
  final String gareArrivee;

  // 👥 Brigade de bord
  final String nomChefDeTrain;
  final String numeroChefDeTrain;

  // ⚠️ Liste des incidents constatés
  final List<String> anomaliesDepart;

  // 📊 Statistiques et comptages de la mission
  final int billetsControles;
  final int voyageursPremiereCl;
  final int voyageursSecondeCl;
  final int comptageRabat;
  final int comptageTerminal;
  final String typeService;

  // 📝 Constructeur principal
  const Mission({
    required this.numeroTrain,
    required this.date,
    required this.heureDepart,
    required this.heureArrivee,
    required this.gareDepart,
    required this.gareArrivee,
    required this.nomChefDeTrain,
    required this.numeroChefDeTrain,
    required this.anomaliesDepart,
    required this.billetsControles,
    required this.voyageursPremiereCl,
    required this.voyageursSecondeCl,
    required this.comptageRabat,
    required this.comptageTerminal,
    required this.typeService,
  });

  // ⚙️ Logique métier : Génération automatique de l'affichage de l'itinéraire
  String get itineraireComplet => "$gareDepart ➔ $gareArrivee";
}
