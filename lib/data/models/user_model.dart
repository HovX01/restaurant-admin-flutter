import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/constants/app_constants.dart';

part 'user_model.g.dart';

/// User model as defined in the API documentation
@JsonSerializable()
class UserModel extends Equatable {
  final int id;
  final String username;
  final String? email;
  final String? fullName;
  @JsonKey(unknownEnumValue: UserRole.manager)
  final UserRole role;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.username,
    this.email,
    this.fullName,
    required this.role,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        fullName,
        role,
        enabled,
        createdAt,
        updatedAt,
      ];

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    UserRole? role,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Login request model
@JsonSerializable()
class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({
    required this.username,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

/// Login response data model
@JsonSerializable()
class LoginData {
  final String token;
  final UserModel user;

  const LoginData({
    required this.token,
    required this.user,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) =>
      _$LoginDataFromJson(json);

  Map<String, dynamic> toJson() => _$LoginDataToJson(this);
}

/// Register request model
@JsonSerializable()
class RegisterRequest {
  final String username;
  final String password;
  final String? email;
  final String? fullName;
  final String role;

  const RegisterRequest({
    required this.username,
    required this.password,
    this.email,
    this.fullName,
    required this.role,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

/// Change password request model
@JsonSerializable()
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);
}
