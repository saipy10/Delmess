import 'package:delmess/core/services/sms_permission_service.dart';
import 'package:delmess/features/onboarding/presentation/screens/permission_explanation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PermissionExplanationScreen Widget Tests', () {
    testWidgets(
      'renders initial permission explanation with Allow SMS Access CTA',
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

        expect(find.text('SMS Access'), findsNWidgets(2)); // Title & Heading
        expect(find.text('Allow SMS Access'), findsOneWidget);
        expect(find.text('Read SMS'), findsOneWidget);
        expect(find.text('No Network Upload'), findsOneWidget);
      },
    );

    testWidgets(
      'displays Try Again and Open Settings buttons when permission is denied',
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
      },
    );

    testWidgets(
      'displays Open Settings button when permission is permanently denied',
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
        expect(find.text('Try Again'), findsNothing);
      },
    );
  });
}
