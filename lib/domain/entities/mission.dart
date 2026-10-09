class Mission {
  final String numeroTrain;
  final String date;
  final String heureDepart;
  final String heureArrivee;
  final String gareDepart;
  final String gareArrivee;
  final String nomChefDeTrain;
  final String numeroChefDeTrain;
  final List<String> anomaliesDepart;

  final int billetsControles;
  final int voyageursPremiereCl;
  final int voyageursSecondeCl; // Unifié en français
  final int comptageRabat;
  final int comptageTerminal;
  final String typeService;

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
    required this.billetsControles,
    required this.voyageursPremiereCl,
    required this.voyageursSecondeCl, // Unifié en français
    required this.comptageRabat,
    required this.comptageTerminal,
    required this.typeService,
  });

  String get itineraireComplet => "$gareDepart ➔ $gareArrivee";
}
