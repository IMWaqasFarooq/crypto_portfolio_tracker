import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// App-wide session state, registered as a singleton.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required AnalyticsService analyticsService,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _analyticsService = analyticsService,
        super(const AuthState.initial()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AnalyticsService _analyticsService;

  Future<void> _onAppStarted(AuthAppStarted event, Emitter<AuthState> emit) async {
    final result = await _getCurrentUserUseCase(const NoParams());
    await result.fold(
      (failure) async => emit(const AuthState.unauthenticated()),
      (user) async {
        if (user == null) {
          emit(const AuthState.unauthenticated());
          return;
        }
        await _analyticsService.setUserId(user.id);
        emit(AuthState.authenticated(user));
      },
    );
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.authenticating());
    final result = await _loginUseCase(LoginParams(email: event.email, password: event.password));
    await result.fold(
      (failure) async => emit(AuthState.unauthenticated(failure: failure)),
      (user) async {
        await _analyticsService.setUserId(user.id);
        await _analyticsService.logEvent('login_success');
        emit(AuthState.authenticated(user));
      },
    );
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    final result = await _logoutUseCase(const NoParams());
    await result.fold(
      (failure) async => emit(AuthState.unauthenticated(failure: failure)),
      (_) async {
        await _analyticsService.setUserId(null);
        emit(const AuthState.unauthenticated());
      },
    );
  }
}
