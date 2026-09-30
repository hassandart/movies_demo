class Mission {
  final String numeroTrain;
  final String nomChefDeTrain;
  final String heureDepart;
  final String heureArrivee;
  final List<String> anomaliesDepart;

  Mission({
    required this.numeroTrain,
    required this.nomChefDeTrain,
    required this.heureDepart,
    required this.heureArrivee,
    required this.anomaliesDepart,
  });
}
