import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String displayName,
    String? avatarUrl,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}

extension UserModelMapper on UserModel {
  User toEntity() => User(id: id, email: email, displayName: displayName, avatarUrl: avatarUrl);
}

extension UserEntityMapper on User {
  UserModel toModel() =>
      UserModel(id: id, email: email, displayName: displayName, avatarUrl: avatarUrl);
}
