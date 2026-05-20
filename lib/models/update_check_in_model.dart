class UpdateCheckInModel {
  UpdateCheckInModel({
    required this.id,
    required this.notes,
    this.dateOfCompletion,
    required this.vehicleServicingId,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  String notes;
  DateTime? dateOfCompletion;
  int vehicleServicingId;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory UpdateCheckInModel.fromJson(Map<String, dynamic> json) => UpdateCheckInModel(
        id: json["id"],
        notes: json["notes"],
        dateOfCompletion: DateTime.parse(json["dateOfCompletion"]),
        vehicleServicingId: json["vehicleServicingId"],
        createdAt: DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: DateTime.parse(json["updatedAt"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "notes": notes,
        "dateOfCompletion": dateOfCompletion?.toIso8601String(),
        "vehicleServicingId": vehicleServicingId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
