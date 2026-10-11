import '../../domain/entities/mission.dart';

class MissionModel extends Mission {
  // 📝 Constructeur transmettant les propriétés à la classe mère via 'super'
  const MissionModel({
    required super.numeroTrain,
    required super.date,
    required super.heureDepart,
    required super.heureArrivee,
    required super.gareDepart,
    required super.gareArrivee,
    required super.nomChefDeTrain,
    required super.numeroChefDeTrain,
    required super.anomaliesDepart,
    required super.billetsControles,
    required super.voyageursPremiereCl,
    required super.voyageursSecondeCl,
    required super.comptageRabat,
    required super.comptageTerminal,
    required super.typeService,
  });

  // 💾 CONVERSION VERS MAP : Préparation des données pour la table 'missions'
  Map<String, dynamic> toMap() {
    return {
      'numeroTrain': numeroTrain,
      'date': date,
      'heureDepart': heureDepart,
      'heureArrivee': heureArrivee,
      'gareDepart': gareDepart,
      'gareArrivee': gareArrivee,
      'nomChefDeTrain': nomChefDeTrain,
      'numeroChefDeTrain': numeroChefDeTrain,
      'billetsControles': billetsControles,
      'voyageursPremiereCl': voyageursPremiereCl,
      'voyageursSecondeCl': voyageursSecondeCl,
      'comptageRabat': comptageRabat,
      'comptageTerminal': comptageTerminal,
      'typeService': typeService,
      // Note : 'anomaliesDepart' est volontairement omis ici car il possède sa propre table SQL
    };
  }

  // 📖 CONVERSION DEPUIS MAP : Réhydratation du modèle depuis SQLite
  // On passe la Map de la table 'missions' et la liste récupérée de la table 'anomalies'
  factory MissionModel.fromMap(
    Map<String, dynamic> map,
    List<String> anomalies,
  ) {
    return MissionModel(
      numeroTrain: map['numeroTrain'] ?? '',
      date: map['date'] ?? '',
      heureDepart: map['heureDepart'] ?? '',
      heureArrivee: map['heureArrivee'] ?? '',
      gareDepart: map['gareDepart'] ?? '',
      gareArrivee: map['gareArrivee'] ?? '',
      nomChefDeTrain: map['nomChefDeTrain'] ?? '',
      numeroChefDeTrain: map['numeroChefDeTrain'] ?? '',
      billetsControles: (map['billetsControles'] ?? 0) as int,
      voyageursPremiereCl: (map['voyageursPremiereCl'] ?? 0) as int,
      voyageursSecondeCl: (map['voyageursSecondeCl'] ?? 0) as int,
      comptageRabat: (map['comptageRabat'] ?? 0) as int,
      comptageTerminal: (map['comptageTerminal'] ?? 0) as int,
      typeService: map['typeService'] ?? 'TRAIN NOMINAL',
      anomaliesDepart: anomalies, // Injection propre des anomalies issues de la table secondaire
    );
  }
}
