import 'models.dart';

class VehicleServicingModel {
  VehicleServicingModel({
    required this.id,
    required this.maintenanceType,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.vehicleId,
    this.vehicle,
  });

  int id;
  String maintenanceType;
  String status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int vehicleId;
  Vehicle? vehicle;

  factory VehicleServicingModel.fromJson(Map<String, dynamic> json) => VehicleServicingModel(
        id: json["id"],
        maintenanceType: json["maintenanceType"],
        status: json["status"],
        createdAt: DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: DateTime.parse(json["updatedAt"]).toLocal(),
        vehicleId: json["vehicleId"],
        vehicle: json["vehicle"] == null ? null : Vehicle.fromJson(json["vehicle"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "maintenanceType": maintenanceType,
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "vehicleId": vehicleId,
        "vehicle": vehicle?.toJson(),
      };
}
