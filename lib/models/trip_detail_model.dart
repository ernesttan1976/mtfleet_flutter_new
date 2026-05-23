import 'dart:convert';

TripDetailModel tripDetailModelFromJson(String str) =>
    TripDetailModel.fromJson(json.decode(str));

String tripDetailModelToJson(TripDetailModel data) =>
    json.encode(data.toJson());

class TripDetailModel {
  TripDetailModel({
    required this.id,
    this.tripDate,
    required this.approvalStatus,
    required this.currentMeterReading,
    required this.tripStatus,
    this.endedAt,
    this.aviDate,
    this.deleted,
    required this.driverId,
    required this.vehiclesId,
    required this.approvingOfficerId,
    this.createdAt,
    this.updatedAt,
    this.mtracForm,
    this.approvingOfficer,
    required this.destinations,
    this.driver,
    this.vehicle,
  });

  int id;
  DateTime? tripDate;
  String approvalStatus;
  int currentMeterReading;
  String tripStatus;
  DateTime? endedAt;
  DateTime? aviDate;
  bool? deleted;
  int driverId;
  int vehiclesId;
  int? approvingOfficerId;
  DateTime? createdAt;
  DateTime? updatedAt;
  MtracForm? mtracForm;
  dynamic approvingOfficer;
  List<Destination> destinations;
  Driver? driver;
  Vehicle? vehicle;

  factory TripDetailModel.fromJson(Map<String, dynamic> json) =>
      TripDetailModel(
        id: json["id"],
        tripDate: json["tripDate"] == null
            ? null
            : DateTime.parse(json["tripDate"]).toLocal(),
        approvalStatus: json["approvalStatus"],
        currentMeterReading: json["currentMeterReading"],
        tripStatus: json["tripStatus"],
        endedAt: json["endedAt"] == null
            ? null
            : DateTime.parse(json["endedAt"]).toLocal(),
        aviDate: json["aviDate"] == null
            ? null
            : DateTime.parse(json["aviDate"]).toLocal(),
        deleted: json["deleted"] ?? false,
        driverId: json["driverId"],
        vehiclesId: json["vehiclesId"],
        approvingOfficerId: json["approvingOfficerId"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]).toLocal(),
        mtracForm: json["MTRACForm"] == null
            ? null
            : MtracForm.fromJson(json["MTRACForm"]),
        approvingOfficer: json["approvingOfficer"],
        destinations: List<Destination>.from(
            (json["destinations"] ?? []).map((x) => Destination.fromJson(x))),
        driver: json["driver"] == null ? null : Driver.fromJson(json["driver"]),
        vehicle:
            json["vehicle"] == null ? null : Vehicle.fromJson(json["vehicle"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tripDate": tripDate?.toIso8601String(),
        "approvalStatus": approvalStatus,
        "currentMeterReading": currentMeterReading,
        "tripStatus": tripStatus,
        "endedAt": endedAt?.toIso8601String(),
        "aviDate": aviDate?.toIso8601String(),
        "deleted": deleted,
        "driverId": driverId,
        "vehiclesId": vehiclesId,
        "approvingOfficerId": approvingOfficerId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "MTRACForm": mtracForm?.toJson(),
        "approvingOfficer": approvingOfficer,
        "destinations": List<dynamic>.from(destinations.map((x) => x.toJson())),
        "driver": driver?.toJson(),
        "vehicle": vehicle?.toJson(),
      };

  List<Destination> sortDestination() {
    destinations.sort((a, b) => a.id.compareTo(b.id));
    return destinations;
  }
}

class Destination {
  Destination(
      {required this.id,
      required this.to,
      required this.requisitionerPurpose,
      this.details,
      required this.deleted,
      this.isAdHocDestination,
      required this.status,
      required this.tripId,
      this.approvingOfficerId,
      required this.approvalStatus,
      this.createdAt,
      this.updatedAt,
      this.eLog});

  int id;
  String to;
  String requisitionerPurpose;
  dynamic details;
  bool? deleted;
  bool? isAdHocDestination;
  String status;
  int tripId;
  int? approvingOfficerId;
  String? approvalStatus;
  DateTime? createdAt;
  DateTime? updatedAt;
  ELog? eLog;

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
        id: json["id"],
        to: json["to"],
        requisitionerPurpose: json["requisitionerPurpose"],
        details: json["details"],
        deleted: json["deleted"] ?? false,
        isAdHocDestination: json["isAdHocDestination"] ?? false,
        status: json["status"],
        tripId: json["tripId"],
        approvingOfficerId: json["approvingOfficerId"],
        approvalStatus: json["approvalStatus"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]).toLocal(),
        eLog: json["eLog"] == null ? null : ELog.fromJson(json["eLog"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "to": to,
        "requisitionerPurpose": requisitionerPurpose,
        "details": details,
        "deleted": deleted,
        "isAdHocDestination": isAdHocDestination,
        "status": status,
        "tripId": tripId,
        "approvingOfficerId": approvingOfficerId,
        "approvalStatus": approvalStatus,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class ELog {
  ELog({
    required this.id,
    this.startTime,
    this.endTime,
  });

  int id;
  DateTime? startTime;
  DateTime? endTime;

  factory ELog.fromJson(Map<String, dynamic> json) => ELog(
        id: json["id"],
        startTime: json["startTime"] == null
            ? null
            : DateTime.parse(json["startTime"]).toLocal(),
        endTime: json["endTime"] == null
            ? null
            : DateTime.parse(json["endTime"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "startTime": startTime?.toIso8601String(),
        "endTime": endTime?.toIso8601String(),
      };
}

class Driver {
  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    this.password,
    required this.deleted,
    required this.provider,
    required this.subUnitId,
    required this.adminSubUnitId,
    this.serviceId,
    this.commandId,
    this.baseAdminId,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  String name;
  String email;
  String username;
  dynamic password;
  bool? deleted;
  String provider;
  int subUnitId;
  int? adminSubUnitId;
  dynamic serviceId;
  dynamic commandId;
  dynamic baseAdminId;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        username: json["username"],
        password: json["password"],
        deleted: json["deleted"] ?? false,
        provider: json["provider"],
        subUnitId: json["subUnitId"],
        adminSubUnitId: json["adminSubUnitId"],
        serviceId: json["serviceId"],
        commandId: json["commandId"],
        baseAdminId: json["baseAdminId"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "username": username,
        "password": password,
        "deleted": deleted,
        "provider": provider,
        "subUnitId": subUnitId,
        "adminSubUnitId": adminSubUnitId,
        "serviceId": serviceId,
        "commandId": commandId,
        "baseAdminId": baseAdminId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class MtracForm {
  MtracForm({
    required this.id,
    required this.overAllRisk,
    this.despatchDate,
    this.despatchTime,
    this.relaseDate,
    this.relaseTime,
    required this.isAdditionalDetailApplicable,
    required this.driverRiskAssessmentChecklist,
    required this.otherRiskAssessmentChecklist,
    this.safetyMeasures,
    required this.rankAndName,
    required this.personalPin,
    required this.deleted,
    required this.filledBy,
    required this.status,
    required this.tripId,
    this.createdAt,
    this.updatedAt,
    this.quizzes,
  });

  int id;
  String overAllRisk;
  DateTime? despatchDate;
  DateTime? despatchTime;
  DateTime? relaseDate;
  DateTime? relaseTime;
  bool? isAdditionalDetailApplicable;
  List<String> driverRiskAssessmentChecklist;
  List<String> otherRiskAssessmentChecklist;
  String? safetyMeasures;
  String? rankAndName;
  String? personalPin;
  bool? deleted;
  String? filledBy;
  String status;
  int tripId;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Quiz>? quizzes;

  factory MtracForm.fromJson(Map<String, dynamic> json) => MtracForm(
        id: json["id"],
        overAllRisk: json["overAllRisk"],
        despatchDate: json["dispatchDate"] == null
            ? null
            : DateTime.parse(json["dispatchDate"]).toLocal(),
        despatchTime: json["dispatchTime"] == null
            ? null
            : DateTime.parse(json["dispatchTime"]).toLocal(),
        relaseDate: json["releaseDate"] == null
            ? null
            : DateTime.parse(json["releaseDate"]).toLocal(),
        relaseTime: json["releaseTime"] == null
            ? null
            : DateTime.parse(json["releaseTime"]).toLocal(),
        isAdditionalDetailApplicable:
            json["isAdditionalDetailApplicable"] ?? false,
        driverRiskAssessmentChecklist: List<String>.from(
            (json["driverRiskAssessmentChecklist"] ?? []).map((x) => x)),
        otherRiskAssessmentChecklist: List<String>.from(
            (json["otherRiskAssessmentChecklist"] ?? []).map((x) => x)),
        safetyMeasures: json["safetyMeasures"],
        rankAndName: json["rankAndName"],
        personalPin: json["personalPin"],
        deleted: json["deleted"] ?? false,
        filledBy: json["filledBy"],
        status: json["status"],
        tripId: json["tripId"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]).toLocal(),
        quizzes: json["quizzes"] != null
            ? List<Quiz>.from(json["quizzes"].map((x) => Quiz.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "overAllRisk": overAllRisk,
        "dispatchDate": despatchDate?.toIso8601String(),
        "dispatchTime": despatchTime?.toIso8601String(),
        "releaseDate": relaseDate?.toIso8601String(),
        "releaseTime": relaseTime?.toIso8601String(),
        "isAdditionalDetailApplicable": isAdditionalDetailApplicable,
        "driverRiskAssessmentChecklist":
            List<dynamic>.from(driverRiskAssessmentChecklist.map((x) => x)),
        "otherRiskAssessmentChecklist":
            List<dynamic>.from(otherRiskAssessmentChecklist.map((x) => x)),
        "safetyMeasures": safetyMeasures,
        "rankAndName": rankAndName,
        "personalPin": personalPin,
        "deleted": deleted,
        "filledBy": filledBy,
        "status": status,
        "tripId": tripId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class Vehicle {
  Vehicle({
    required this.id,
    required this.vehicleNumber,
    required this.model,
    required this.isServiceable,
    required this.deleted,
    required this.vehicleType,
    required this.subUnitId,
    required this.vehiclesPlatformsId,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  String vehicleNumber;
  String model;
  bool? isServiceable;
  bool? deleted;
  String vehicleType;
  int subUnitId;
  int vehiclesPlatformsId;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json["id"],
        vehicleNumber: json["vehicleNumber"],
        model: json["model"],
        isServiceable: json["isServiceable"] ?? false,
        deleted: json["deleted"] ?? false,
        vehicleType: json["vehicleType"],
        subUnitId: json["subUnitId"],
        vehiclesPlatformsId: json["vehiclesPlatformsId"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "vehicleNumber": vehicleNumber,
        "model": model,
        "isServiceable": isServiceable,
        "deleted": deleted,
        "vehicleType": vehicleType,
        "subUnitId": subUnitId,
        "vehiclesPlatformsId": vehiclesPlatformsId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class Quiz {
  Quiz({
    required this.id,
    required this.question,
    required this.answer,
    required this.mtracFormId,
  });

  int id;
  String question;
  String answer;
  int mtracFormId;

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
        id: json["id"],
        question: json["question"],
        answer: json["answer"],
        mtracFormId: json["MTRACFormId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "question": question,
        "answer": answer,
        "MTRACFormId": mtracFormId,
      };
}
