import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.appStarted() = AuthAppStarted;
  const factory AuthEvent.loginRequested({required String email, required String password}) =
      AuthLoginRequested;
  const factory AuthEvent.logoutRequested() = AuthLogoutRequested;
}
