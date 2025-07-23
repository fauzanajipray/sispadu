class Report {
  int? id;
  String? title;
  int? userId;
  String? content;
  String? status;
  dynamic tempPositionId;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? canTakeAction;
  UserSimple? user;
  List<Image>? images;
  List<StatusLog>? statusLogs;

  Report({
    this.id,
    this.title,
    this.userId,
    this.content,
    this.status,
    this.tempPositionId,
    this.createdAt,
    this.updatedAt,
    this.canTakeAction,
    this.user,
    this.images,
    this.statusLogs,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json["id"],
        title: json["title"],
        userId: int.tryParse('${json["user_id"]}'),
        content: json["content"],
        status: json["status"],
        tempPositionId: int.tryParse('${json["temp_position_id"]}'),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        canTakeAction: json["can_take_action"],
        user: json["user"] == null ? null : UserSimple.fromJson(json["user"]),
        images: json["images"] == null
            ? []
            : List<Image>.from(json["images"]!.map((x) => Image.fromJson(x))),
        statusLogs: json["status_logs"] == null
            ? []
            : List<StatusLog>.from(
                json["status_logs"]!.map((x) => StatusLog.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "user_id": userId,
        "content": content,
        "status": status,
        "temp_position_id": tempPositionId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "can_take_action": canTakeAction,
        "user": user?.toJson(),
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toJson())),
        "status_logs": statusLogs == null
            ? []
            : List<dynamic>.from(statusLogs!.map((x) => x.toJson())),
      };
}

class Image {
  int? id;
  int? reportId;
  String? imagePath;
  DateTime? createdAt;
  DateTime? updatedAt;

  Image({
    this.id,
    this.reportId,
    this.imagePath,
    this.createdAt,
    this.updatedAt,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        id: json["id"],
        reportId: int.tryParse(json["report_id"]),
        imagePath: json["image_path"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "report_id": reportId,
        "image_path": imagePath,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class StatusLog {
  int? id;
  int? reportId;
  int? userId;
  dynamic positionId;
  String? fromStatus;
  String? toStatus;
  String? note;
  int? dispositionId;
  DateTime? createdAt;
  DateTime? updatedAt;
  UserSimple? user;
  dynamic position;
  Disposition? disposition;

  StatusLog({
    this.id,
    this.reportId,
    this.userId,
    this.positionId,
    this.fromStatus,
    this.toStatus,
    this.note,
    this.dispositionId,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.position,
    this.disposition,
  });

  factory StatusLog.fromJson(Map<String, dynamic> json) => StatusLog(
        id: json["id"],
        reportId: int.tryParse('${json["report_id"]}'),
        userId: int.tryParse('${json["user_id"]}'),
        positionId: int.tryParse('${json["position_id"]}'),
        fromStatus: json["from_status"],
        toStatus: json["to_status"],
        note: json["note"],
        dispositionId: int.tryParse('${json["disposition_id"]}'),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        user: json["user"] == null ? null : UserSimple.fromJson(json["user"]),
        position: json["position"],
        disposition: json["disposition"] == null
            ? null
            : Disposition.fromJson(json["disposition"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "report_id": reportId,
        "user_id": userId,
        "position_id": positionId,
        "from_status": fromStatus,
        "to_status": toStatus,
        "note": note,
        "disposition_id": dispositionId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "user": user?.toJson(),
        "position": position,
        "disposition": disposition?.toJson(),
      };
}

class Disposition {
  int? id;
  int? reportId;
  dynamic fromPositionId;
  int? toPositionId;
  String? note;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic fromPosition;
  UserSimple? toPosition;

  Disposition({
    this.id,
    this.reportId,
    this.fromPositionId,
    this.toPositionId,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.fromPosition,
    this.toPosition,
  });

  factory Disposition.fromJson(Map<String, dynamic> json) => Disposition(
        id: json["id"],
        reportId: int.tryParse('${json["report_id"]}'),
        fromPositionId: int.tryParse('${json["from_position_id"]}'),
        toPositionId: int.tryParse('${json["to_position_id"]}'),
        note: json["note"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        fromPosition: json["from_position"],
        toPosition: json["to_position"] == null
            ? null
            : UserSimple.fromJson(json["to_position"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "report_id": reportId,
        "from_position_id": fromPositionId,
        "to_position_id": toPositionId,
        "note": note,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "from_position": fromPosition,
        "to_position": toPosition?.toJson(),
      };
}

class UserSimple {
  int? id;
  String? name;

  UserSimple({
    this.id,
    this.name,
  });

  factory UserSimple.fromJson(Map<String, dynamic> json) => UserSimple(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
