import 'dart:convert';

AdHocDestinationModel adHocDestinationModelFromJson(String str) => AdHocDestinationModel.fromJson(json.decode(str));

String adHocDestinationModelToJson(AdHocDestinationModel data) => json.encode(data.toJson());

class AdHocDestinationModel {
  AdHocDestinationModel({
    required this.id,
    required this.to,
    required this.requisitionerPurpose,
    required this.details,
    required this.isAdHocDestination,
    required this.status,
    required this.tripId,
    required this.approvingOfficerId,
    required this.approvalStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String to;
  String requisitionerPurpose;
  String details;
  bool isAdHocDestination;
  String status;
  int tripId;
  int approvingOfficerId;
  String approvalStatus;
  DateTime createdAt;
  DateTime updatedAt;

  factory AdHocDestinationModel.fromJson(Map<String, dynamic> json) => AdHocDestinationModel(
        id: json["id"],
        to: json["to"],
        requisitionerPurpose: json["requisitionerPurpose"],
        details: json["details"],
        isAdHocDestination: json["isAdHocDestination"],
        status: json["status"],
        tripId: json["tripId"],
        approvingOfficerId: json["approvingOfficerId"],
        approvalStatus: json["approvalStatus"],
        createdAt: DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: DateTime.parse(json["updatedAt"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "to": to,
        "requisitionerPurpose": requisitionerPurpose,
        "details": details,
        "isAdHocDestination": isAdHocDestination,
        "status": status,
        "tripId": tripId,
        "approvingOfficerId": approvingOfficerId,
        "approvalStatus": approvalStatus,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
