import 'dart:convert';

class User {
  int? id;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  String? role;
  int? positionId;
  DateTime? createdAt;
  DateTime? updatedAt;
  Position? position;

  User({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.role,
    this.positionId,
    this.createdAt,
    this.updatedAt,
    this.position,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        role: json["role"],
        positionId: json["position_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        position: json["position"] == null
            ? null
            : Position.fromJson(json["position"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "role": role,
        "position_id": positionId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "position": position?.toJson(),
      };

  String toRawJson() {
    return toJson().toString();
  }

  User fromRawJson(String str) => User.fromJson(json.decode(str));
}

class Position {
  int? id;
  String? name;
  String? detail;
  int? parentId;
  DateTime? createdAt;
  DateTime? updatedAt;

  Position({
    this.id,
    this.name,
    this.detail,
    this.parentId,
    this.createdAt,
    this.updatedAt,
  });

  factory Position.fromJson(Map<String, dynamic> json) => Position(
        id: json["id"],
        name: json["name"],
        detail: json["detail"],
        parentId: json["parent_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "detail": detail,
        "parent_id": parentId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
