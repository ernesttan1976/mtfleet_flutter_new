class ELogVehicleModel {
  ELogVehicleModel({
    required this.id,
    required this.vehicleNumber,
    required this.tripDate,
    required this.to,
    required this.requisitionerPurpose,
    required this.tripStatus,
    required this.startTime,
    required this.endTime,
    required this.stationaryRunningTime,
    required this.meterReading,
    required this.totalDistance,
    required this.driverName,
    required this.approvingOfficer,
  });

/*
* [{"id":19517,"vehicleNumber":"1442","tripDate":"2022-12-20T07:28:42.023Z","to":"Demo Testing","requisitionerPurpose":"Testing","tripStatus":"InProgress","startTime":"2022-12-23T09:45:00.000Z","endTime":null,"stationaryRunningTime":null,"meterReading":3600,"totalDistance":0,"driverName":"Demo Transport - Driver Test","approvingOfficer":"Demo Transport - Approving Officer Test"}]
* */
  int id;
  String vehicleNumber;
  DateTime? tripDate;
  String to;
  String requisitionerPurpose;
  String tripStatus;
  DateTime? startTime;
  DateTime? endTime;
  int? stationaryRunningTime;
  num meterReading;
  num totalDistance;
  String driverName;
  String? approvingOfficer;

  factory ELogVehicleModel.fromJson(Map<String, dynamic> json) => ELogVehicleModel(
        id: json["id"],
        vehicleNumber: json["vehicleNumber"],
        tripDate: json["tripDate"] == null ? null : DateTime.parse(json["tripDate"]).toUtc(),
        to: json["to"],
        requisitionerPurpose: json["requisitionerPurpose"],
        tripStatus: json["tripStatus"],
        startTime: json["startTime"] == null ? null : DateTime.parse(json["startTime"]).toLocal(),
        endTime: json["endTime"] == null ? null : DateTime.parse(json["endTime"]).toLocal(),
        stationaryRunningTime: json["stationaryRunningTime"],
        meterReading: json["meterReading"],
        totalDistance: json["totalDistance"],
        driverName: json["driverName"],
        approvingOfficer: json["approvingOfficer"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "vehicleNumber": vehicleNumber,
        "tripDate": tripDate?.toIso8601String(),
        "to": to,
        "requisitionerPurpose": requisitionerPurpose,
        "tripStatus": tripStatus,
        "startTime": startTime?.toIso8601String(),
        "endTime": endTime?.toIso8601String(),
        "stationaryRunningTime": stationaryRunningTime,
        "meterReading": meterReading,
        "totalDistance": totalDistance,
        "driverName": driverName,
        "approvingOfficer": approvingOfficer,
      };
}

class ELogBapVehicleModel {
  ELogBapVehicleModel({
    required this.id,
    this.tripDate,
    this.startTime,
    this.endTime,
    required this.meterReading,
    required this.requisitionerPurpose,
    required this.driverName,
  });

  int id;
  DateTime? tripDate;
  DateTime? startTime;
  DateTime? endTime;
  num meterReading;
  String requisitionerPurpose;
  String driverName;

  factory ELogBapVehicleModel.fromJson(Map<String, dynamic> json) => ELogBapVehicleModel(
    id: json["id"],
        tripDate: json["tripDate"] == null ? null : DateTime.parse(json["tripDate"]).toUtc(),
        startTime: json["startTime"] == null ? null : DateTime.parse(json["startTime"]).toLocal(),
        endTime: json["endTime"] == null ? null : DateTime.parse(json["endTime"]).toLocal(),
        meterReading: json["meterReading"],
        requisitionerPurpose: json["requisitionerPurpose"],
        driverName: json["driverName"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tripDate": tripDate?.toIso8601String(),
        "startTime": startTime?.toIso8601String(),
        "endTime": endTime?.toIso8601String(),
        "meterReading": meterReading,
        "requisitionerPurpose": requisitionerPurpose,
        "driverName": driverName,
      };
}
