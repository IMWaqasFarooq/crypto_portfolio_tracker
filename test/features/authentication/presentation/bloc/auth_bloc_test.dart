import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/core/services/analytics_service.dart';
import 'package:crypto_portfolio_tracker/core/usecase/usecase.dart';
import 'package:crypto_portfolio_tracker/features/authentication/domain/entities/user.dart';
import 'package:crypto_portfolio_tracker/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:crypto_portfolio_tracker/features/authentication/domain/usecases/login_usecase.dart';
import 'package:crypto_portfolio_tracker/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:crypto_portfolio_tracker/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:crypto_portfolio_tracker/features/authentication/presentation/bloc/auth_event.dart';
import 'package:crypto_portfolio_tracker/features/authentication/presentation/bloc/auth_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockLogoutUseCase extends Mock implements LogoutUseCase {}

class _MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late _MockLoginUseCase loginUseCase;
  late _MockLogoutUseCase logoutUseCase;
  late _MockGetCurrentUserUseCase getCurrentUserUseCase;
  late _MockAnalyticsService analyticsService;

  const user = User(id: '1', email: 'demo@cryptofolio.dev', displayName: 'Demo');

  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    loginUseCase = _MockLoginUseCase();
    logoutUseCase = _MockLogoutUseCase();
    getCurrentUserUseCase = _MockGetCurrentUserUseCase();
    analyticsService = _MockAnalyticsService();
    when(() => analyticsService.setUserId(any())).thenAnswer((_) async {});
    when(() => analyticsService.logEvent(any(), parameters: any(named: 'parameters')))
        .thenAnswer((_) async {});
  });

  AuthBloc buildBloc() => AuthBloc(
        loginUseCase: loginUseCase,
        logoutUseCase: logoutUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
        analyticsService: analyticsService,
      );

  blocTest<AuthBloc, AuthState>(
    'emits [authenticated] when a session is restored on app start',
    build: () {
      when(() => getCurrentUserUseCase(any())).thenAnswer((_) async => const Right(user));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AuthEvent.appStarted()),
    expect: () => [const AuthState.authenticated(user)],
    verify: (_) => verify(() => analyticsService.setUserId('1')).called(1),
  );

  blocTest<AuthBloc, AuthState>(
    'emits [unauthenticated] when no session is cached on app start',
    build: () {
      when(() => getCurrentUserUseCase(any())).thenAnswer((_) async => const Right(null));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AuthEvent.appStarted()),
    expect: () => [const AuthState.unauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [unauthenticated] when restoring the session fails',
    build: () {
      when(() => getCurrentUserUseCase(any()))
          .thenAnswer((_) async => const Left(Failure.cache()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AuthEvent.appStarted()),
    expect: () => [const AuthState.unauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [authenticating, authenticated] on a successful login',
    build: () {
      when(() => loginUseCase(any())).thenAnswer((_) async => const Right(user));
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      const AuthEvent.loginRequested(email: 'demo@cryptofolio.dev', password: 'password123'),
    ),
    expect: () => [
      const AuthState.authenticating(),
      const AuthState.authenticated(user),
    ],
    verify: (_) {
      verify(() => analyticsService.setUserId('1')).called(1);
      verify(() => analyticsService.logEvent('login_success')).called(1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'emits [authenticating, unauthenticated(failure)] on a failed login',
    build: () {
      when(() => loginUseCase(any())).thenAnswer(
        (_) async => const Left(Failure.validation(message: 'Enter a valid email address')),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      const AuthEvent.loginRequested(email: 'bad', password: 'password123'),
    ),
    expect: () => [
      const AuthState.authenticating(),
      const AuthState.unauthenticated(
        failure: Failure.validation(message: 'Enter a valid email address'),
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [unauthenticated] and clears the analytics user id on logout',
    build: () {
      when(() => logoutUseCase(any())).thenAnswer((_) async => const Right(null));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AuthEvent.logoutRequested()),
    expect: () => [const AuthState.unauthenticated()],
    verify: (_) => verify(() => analyticsService.setUserId(null)).called(1),
  );
}
