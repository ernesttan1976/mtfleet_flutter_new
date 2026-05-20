import 'dart:convert';

VehicleServicingDetailModel vehicleServicingDetailModelFromJson(String str) =>
    VehicleServicingDetailModel.fromJson(json.decode(str));

String vehicleServicingDetailModelToJson(VehicleServicingDetailModel data) => json.encode(data.toJson());

class VehicleServicingDetailModel {
  VehicleServicingDetailModel({
    required this.id,
    required this.workCenter,
    required this.telephoneNo,
    this.dateIn,
    required this.speedoReading,
    required this.swdReading,
    this.expectedCheckoutDate,
    this.expectedCheckoutTime,
    required this.handedBy,
    required this.attender,
    this.deleted,
    required this.checkInType,
    required this.frontSensorTag,
    required this.vehicleServicingId,
    this.createdAt,
    this.updatedAt,
    this.fileId,
    this.correctiveMaintenance,
    this.vehicleServicing,
    required this.basicIssueTools,
    required this.images,
  });

  int id;
  String workCenter;
  String telephoneNo;
  DateTime? dateIn;
  String speedoReading;
  String swdReading;
  DateTime? expectedCheckoutDate;
  DateTime? expectedCheckoutTime;
  String handedBy;
  String attender;
  bool? deleted;
  String checkInType;
  String frontSensorTag;
  int vehicleServicingId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic fileId;
  CorrectiveMaintenance? correctiveMaintenance;
  VehicleServicing? vehicleServicing;
  List<BasicIssueTool> basicIssueTools;
  List<ImageCheckIn> images;

  factory VehicleServicingDetailModel.fromJson(Map<String, dynamic> json) => VehicleServicingDetailModel(
        id: json["id"],
        workCenter: json["workCenter"],
        telephoneNo: json["telephoneNo"],
        dateIn: json["dateIn"] == null ? null : DateTime.parse(json["dateIn"]),
        speedoReading: json["speedoReading"],
        swdReading: json["swdReading"],
        expectedCheckoutDate:
            json["expectedCheckoutDate"] == null ? null : DateTime.parse(json["expectedCheckoutDate"]).toLocal(),
        expectedCheckoutTime:
            json["expectedCheckoutTime"] == null ? null : DateTime.parse(json["expectedCheckoutTime"]).toLocal(),
        handedBy: json["handedBy"],
        attender: json["attender"],
        deleted: json["deleted"],
        checkInType: json["checkInType"],
        frontSensorTag: json["frontSensorTag"],
        vehicleServicingId: json["vehicleServicingId"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        fileId: json["fileId"],
        correctiveMaintenance: json["correctiveMaintenance"] == null
            ? null
            : CorrectiveMaintenance.fromJson(json["correctiveMaintenance"]),
        vehicleServicing: json["vehicleServicing"] == null ? null : VehicleServicing.fromJson(json["vehicleServicing"]),
        basicIssueTools: json["basicIssueTools"] == null
            ? []
            : List<BasicIssueTool>.from(json["basicIssueTools"].map((x) => BasicIssueTool.fromJson(x))),
        images:
            json["images"] == null ? [] : List<ImageCheckIn>.from(json["images"].map((x) => ImageCheckIn.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "workCenter": workCenter,
        "telephoneNo": telephoneNo,
        "dateIn": dateIn?.toIso8601String(),
        "speedoReading": speedoReading,
        "swdReading": swdReading,
        "expectedCheckoutDate": expectedCheckoutDate?.toIso8601String(),
        "expectedCheckoutTime": expectedCheckoutTime?.toIso8601String(),
        "handedBy": handedBy,
        "attender": attender,
        "deleted": deleted,
        "checkInType": checkInType,
        "frontSensorTag": frontSensorTag,
        "vehicleServicingId": vehicleServicingId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "fileId": fileId,
        "correctiveMaintenance": correctiveMaintenance?.toJson(),
        "vehicleServicing": vehicleServicing?.toJson(),
        "basicIssueTools": List<dynamic>.from(basicIssueTools.map((x) => x.toJson())),
        "images": List<dynamic>.from(images.map((x) => x.toJson())),
      };
}

class BasicIssueTool {
  BasicIssueTool({
    required this.id,
    required this.name,
    required this.quantity,
    this.deleted,
    required this.checkInId,
    this.checkOutId,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  String name;
  int quantity;
  bool? deleted;
  int checkInId;
  dynamic checkOutId;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory BasicIssueTool.fromJson(Map<String, dynamic> json) => BasicIssueTool(
        id: json["id"],
        name: json["name"],
        quantity: json["quantity"],
        deleted: json["deleted"],
        checkInId: json["checkInId"],
        checkOutId: json["checkOutId"],
        createdAt: DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: DateTime.parse(json["updatedAt"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "quantity": quantity,
        "deleted": deleted,
        "checkInId": checkInId,
        "checkOutId": checkOutId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class CorrectiveMaintenance {
  CorrectiveMaintenance({
    required this.id,
    required this.correctiveMaintenance,
    required this.deleted,
    required this.checkinId,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  String correctiveMaintenance;
  bool? deleted;
  int checkinId;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory CorrectiveMaintenance.fromJson(Map<String, dynamic> json) => CorrectiveMaintenance(
        id: json["id"],
        correctiveMaintenance: json["correctiveMaintenance"],
        deleted: json["deleted"],
        checkinId: json["checkinId"],
        createdAt: DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: DateTime.parse(json["updatedAt"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "correctiveMaintenance": correctiveMaintenance,
        "deleted": deleted,
        "checkinId": checkinId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class ImageCheckIn {
  ImageCheckIn({
    required this.id,
    required this.originalName,
    required this.encoding,
    required this.mimetype,
    required this.path,
    required this.size,
    required this.checkInId,
    this.mTBroadcastId,
  });

  int id;
  String originalName;
  String encoding;
  String mimetype;
  String path;
  int size;
  int checkInId;
  dynamic mTBroadcastId;

  factory ImageCheckIn.fromJson(Map<String, dynamic> json) => ImageCheckIn(
        id: json["id"],
        originalName: json["originalName"],
        encoding: json["encoding"],
        mimetype: json["mimetype"],
        path: json["path"],
        size: json["size"],
        checkInId: json["checkInId"],
        mTBroadcastId: json["mTBroadcastId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "originalName": originalName,
        "encoding": encoding,
        "mimetype": mimetype,
        "path": path,
        "size": size,
        "checkInId": checkInId,
        "mTBroadcastId": mTBroadcastId,
      };
}

class VehicleServicing {
  VehicleServicing({
    required this.id,
    required this.maintenanceType,
    this.deleted,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.vehicleId,
  });

  int id;
  String maintenanceType;
  bool? deleted;
  String status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int vehicleId;

  factory VehicleServicing.fromJson(Map<String, dynamic> json) => VehicleServicing(
        id: json["id"],
        maintenanceType: json["maintenanceType"],
        deleted: json["deleted"],
        status: json["status"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        vehicleId: json["vehicleId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "maintenanceType": maintenanceType,
        "deleted": deleted,
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "vehicleId": vehicleId,
      };
}
