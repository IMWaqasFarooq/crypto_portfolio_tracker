import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_portfolio_tracker/core/error/failures.dart';
import 'package:crypto_portfolio_tracker/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:crypto_portfolio_tracker/features/authentication/presentation/bloc/auth_event.dart';
import 'package:crypto_portfolio_tracker/features/authentication/presentation/bloc/auth_state.dart';
import 'package:crypto_portfolio_tracker/features/authentication/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late _MockAuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(const AuthEvent.appStarted());
  });

  setUp(() {
    authBloc = _MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthState.unauthenticated());
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.unauthenticated());
  });

  Widget wrap() => MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const LoginPage(),
        ),
      );

  testWidgets('renders the welcome copy and both input fields', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.text('Welcome to Cryptofolio'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('dispatches loginRequested with the entered credentials on Sign in', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.enterText(find.byType(TextField).at(0), 'demo@cryptofolio.dev');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.text('Sign in'));

    verify(() => authBloc.add(
          const AuthEvent.loginRequested(email: 'demo@cryptofolio.dev', password: 'password123'),
        )).called(1);
  });

  testWidgets('shows a spinner instead of the label while authenticating', (tester) async {
    when(() => authBloc.state).thenReturn(const AuthState.authenticating());
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthState.authenticating(),
    );

    await tester.pumpWidget(wrap());

    expect(find.text('Sign in'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows a snackbar with the failure message on a failed login', (tester) async {
    whenListen(
      authBloc,
      Stream.fromIterable([
        const AuthState.unauthenticated(failure: Failure.validation(message: 'Enter a valid email address')),
      ]),
      initialState: const AuthState.unauthenticated(),
    );

    await tester.pumpWidget(wrap());
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });
}
