import 'models.dart';

class TripDriverModel {
  TripDriverModel({
    required this.id,
    this.tripDate,
    required this.approvalStatus,
    required this.currentMeterReading,
    required this.tripStatus,
    this.endedAt,
    this.aviDate,
    required this.driverId,
    required this.vehiclesId,
    required this.approvingOfficerId,
    this.createdAt,
    this.updatedAt,
    required this.destinations,
    required this.riskAssessment,
    required this.driverName,
    required this.vehicleNumber,
  });

  int id;
  DateTime? tripDate;
  String approvalStatus;
  int currentMeterReading;
  String tripStatus;
  DateTime? endedAt;
  DateTime? aviDate;
  int driverId;
  int vehiclesId;
  int? approvingOfficerId;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Destination> destinations;
  String? riskAssessment;
  String? vehicleNumber;
  String? driverName;

  factory TripDriverModel.fromJson(Map<String, dynamic> json) => TripDriverModel(
        id: json["id"],
        tripDate: json["tripDate"] == null ? null : DateTime.parse(json["tripDate"]).toLocal(),
        approvalStatus: json["approvalStatus"],
        currentMeterReading: json["currentMeterReading"],
        tripStatus: json["tripStatus"],
        endedAt: json["endedAt"] == null ? null : DateTime.parse(json["endedAt"]).toLocal(),
        aviDate: json["aviDate"] == null ? null : DateTime.parse(json["aviDate"]).toLocal(),
        driverId: json["driverId"],
        vehiclesId: json["vehiclesId"],
        driverName: json["driverName"] == null ? null : json["driverName"],
        vehicleNumber: json["vehicleNumber"] == null ? null : json["vehicleNumber"],
        approvingOfficerId: json["approvingOfficerId"] == null ? null : json["approvingOfficerId"],
        destinations: json["destinations"] == null
            ? []
            : List<Destination>.from(json["destinations"].map((x) => Destination.fromJson(x))),
        riskAssessment: json["riskAssessment"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tripDate": tripDate?.toIso8601String(),
        "approvalStatus": approvalStatus,
        "currentMeterReading": currentMeterReading,
        "tripStatus": tripStatus,
        "endedAt": endedAt?.toIso8601String(),
        "aviDate": aviDate?.toIso8601String(),
        "driverId": driverId,
        "vehiclesId": vehiclesId,
        "approvingOfficerId": approvingOfficerId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "destinations": List<dynamic>.from(destinations.map((x) => x.toJson())),
        "riskAssessment": riskAssessment,
      };
}
