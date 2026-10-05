import '../../domain/entities/mission.dart';

class MissionModel extends Mission {
  MissionModel({
    required super.numeroTrain,
    required super.date,
    required super.heureDepart,
    required super.heureArrivee,
    required super.gareDepart,
    required super.gareArrivee,
    required super.nomChefDeTrain,
    required super.numeroChefDeTrain,
    required super.anomaliesDepart,
    required super.nombreVoitures,
    required super.voyagersPremiereCl,
    required super.voyagersSecondeCl,
    required super.billetsControles,
  });

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
      'nombreVoitures': nombreVoitures,
      'voyagersPremiereCl': voyagersPremiereCl,
      'voyagersSecondeCl': voyagersSecondeCl,
      'billetsControles': billetsControles,
    };
  }

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
      anomaliesDepart: anomalies,
      nombreVoitures: map['nombreVoitures'] ?? 8,
      voyagersPremiereCl: map['voyagersPremiereCl'] ?? 0,
      voyagersSecondeCl: map['voyagersSecondeCl'] ?? 0,
      billetsControles: map['billetsControles'] ?? 0,
    );
  }
}
