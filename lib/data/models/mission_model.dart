import '../../domain/entities/mission.dart';

class MissionModel extends Mission {
  MissionModel({
    required super.numeroTrain,
    required super.nomChefDeTrain,
    required super.heureDepart,
    required super.heureArrivee,
    required super.anomaliesDepart,
  });

  // Convertit notre objet en format Map (Clé / Valeur) pour sqflite
  Map<String, dynamic> toMap() {
    return {
      'numeroTrain': numeroTrain,
      'nomChefDeTrain': nomChefDeTrain,
      'heureDepart': heureDepart,
      'heureArrivee': heureArrivee,
    };
  }

  // Recrée l'objet Mission à partir des lignes lues depuis sqflite
  factory MissionModel.fromMap(
    Map<String, dynamic> map,
    List<String> anomalies,
  ) {
    return MissionModel(
      numeroTrain: map['numeroTrain'],
      nomChefDeTrain: map['nomChefDeTrain'],
      heureDepart: map['heureDepart'],
      heureArrivee: map['heureArrivee'],
      anomaliesDepart: anomalies,
    );
  }
}
