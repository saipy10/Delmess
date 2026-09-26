import 'package:delmess/core/routing/route_paths.dart';
import 'package:delmess/core/services/sms_permission_service.dart';
import '../helpers/fake_sms_permission_service.dart';
import 'package:delmess/features/onboarding/presentation/screens/permission_explanation_screen.dart';
import 'package:delmess/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Phase 4 — PermissionExplanationScreen Prominent Disclosure Tests', () {
    testWidgets(
      'renders prominent disclosure with explicit READ_SMS, RECEIVE_SMS, local processing, and clear choices',
      (tester) async {
        final fakePermissionService = FakeSmsPermissionService(
          initialState: SmsPermissionState.unknown,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              smsPermissionServiceProvider.overrideWithValue(
                fakePermissionService,
              ),
            ],
            child: const MaterialApp(home: PermissionExplanationScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Header and Title
        expect(find.text('SMS Access'), findsNWidgets(2)); // AppBar & Headline
        expect(
          find.text('100% On-Device • Zero Network Upload'),
          findsOneWidget,
        );

        // Explicit Permission Names
        expect(
          find.textContaining('Read SMS (android.permission.READ_SMS)'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Receive SMS (android.permission.RECEIVE_SMS)'),
          findsOneWidget,
        );
        expect(
          find.textContaining('100% Local On-Device Processing'),
          findsOneWidget,
        );
        expect(find.textContaining('No Network Upload'), findsOneWidget);

        // Clear choices for the user
        expect(find.text('Allow SMS Access'), findsOneWidget);
        expect(find.text('Not Now'), findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);
      },
    );

    testWidgets(
      'displays Try Again, Open Settings, and Continue Without SMS when permission is denied',
      (tester) async {
        final fakePermissionService = FakeSmsPermissionService(
          initialState: SmsPermissionState.denied,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              smsPermissionServiceProvider.overrideWithValue(
                fakePermissionService,
              ),
            ],
            child: const MaterialApp(home: PermissionExplanationScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('SMS access is required'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);
        expect(find.text('Open Settings'), findsOneWidget);
        expect(find.text('Continue Without SMS'), findsOneWidget);
      },
    );

    testWidgets(
      'displays Open Settings when permission is permanently denied ("Don\'t ask again")',
      (tester) async {
        final fakePermissionService = FakeSmsPermissionService(
          initialState: SmsPermissionState.permanentlyDenied,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              smsPermissionServiceProvider.overrideWithValue(
                fakePermissionService,
              ),
            ],
            child: const MaterialApp(home: PermissionExplanationScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('SMS access is required'), findsOneWidget);
        expect(find.text('Open Settings'), findsOneWidget);
        expect(find.text('Continue Without SMS'), findsOneWidget);
        expect(find.text('Try Again'), findsNothing);
      },
    );

    testWidgets(
      'tapping Not Now gracefully dismisses disclosure and provides feedback',
      (tester) async {
        final fakePermissionService = FakeSmsPermissionService(
          initialState: SmsPermissionState.unknown,
        );

        final router = GoRouter(
          initialLocation: RoutePaths.permissions,
          routes: [
            GoRoute(
              path: RoutePaths.permissions,
              builder: (context, state) => const PermissionExplanationScreen(),
            ),
            GoRoute(
              path: RoutePaths.inbox,
              builder: (context, state) => const Scaffold(
                body: Text('Inbox Screen Mock'),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              smsPermissionServiceProvider.overrideWithValue(
                fakePermissionService,
              ),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Not Now
        await tester.tap(find.text('Not Now'));
        await tester.pumpAndSettle();

        // Verify routed gracefully to Inbox with SnackBar
        expect(find.text('Inbox Screen Mock'), findsOneWidget);
        expect(
          find.textContaining('SMS access declined'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'first-install onboarding flow: Welcome -> Disclosure -> Grant -> Import',
      (tester) async {
        final fakePermissionService = FakeSmsPermissionService(
          initialState: SmsPermissionState.unknown,
        );

        final router = GoRouter(
          initialLocation: RoutePaths.welcome,
          routes: [
            GoRoute(
              path: RoutePaths.welcome,
              builder: (context, state) => const WelcomeScreen(),
            ),
            GoRoute(
              path: RoutePaths.permissions,
              builder: (context, state) => const PermissionExplanationScreen(),
            ),
            GoRoute(
              path: RoutePaths.import,
              builder: (context, state) => const Scaffold(
                body: Text('Import Screen Mock'),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              smsPermissionServiceProvider.overrideWithValue(
                fakePermissionService,
              ),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Welcome screen is visible
        expect(find.text('Welcome to DelMess'), findsOneWidget);
        expect(find.text('Smart Indian SMS Categorization'), findsOneWidget);

        // 2. Tap Get Started CTA
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        // 3. Prominent Disclosure screen is reached
        expect(find.text('SMS Access'), findsNWidgets(2));
        expect(
          find.textContaining('Read SMS (android.permission.READ_SMS)'),
          findsOneWidget,
        );

        // 4. Tap Allow SMS Access
        await tester.tap(find.text('Allow SMS Access'));
        await tester.pumpAndSettle();

        // 5. User transitions to SMS Import
        expect(find.text('Import Screen Mock'), findsOneWidget);
      },
    );
  });
}
