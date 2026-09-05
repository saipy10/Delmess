import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/classification/domain/message_category.dart';
import '../../features/inbox/presentation/screens/archived_messages_screen.dart';
import '../../features/inbox/presentation/screens/category_messages_screen.dart';
import '../../features/inbox/presentation/screens/deleted_messages_screen.dart';
import '../../features/inbox/presentation/screens/inbox_screen.dart';
import '../../features/inbox/presentation/screens/pinned_messages_screen.dart';
import '../../features/inbox/presentation/screens/starred_messages_screen.dart';
import '../../features/inbox/presentation/screens/sms_import_screen.dart';
import '../../features/labels/presentation/screens/label_detail_screen.dart';
import '../../features/labels/presentation/screens/labels_screen.dart';
import '../../features/messages/presentation/screens/message_detail_screen.dart';
import '../../features/onboarding/presentation/screens/permission_explanation_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/about_settings_screen.dart';
import '../../features/settings/presentation/screens/appearance_settings_screen.dart';
import '../../features/settings/presentation/screens/general_settings_screen.dart';
import '../../features/settings/presentation/screens/notifications_settings_screen.dart';
import '../../features/settings/presentation/screens/organization_settings_screen.dart';
import '../../features/settings/presentation/screens/privacy_settings_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/responsive_scaffold.dart';
import 'route_paths.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');
final inboxNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'inboxNav');
final searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'searchNav');
final labelsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'labelsNav');
final settingsNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'settingsNav',
);

/// Central AppRouter definition using GoRouter and StatefulShellRoute.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RoutePaths.inbox,
    routes: [
      // Onboarding Routes
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
        builder: (context, state) => const SmsImportScreen(),
      ),

      // Standalone Top-Level Sub-Routes
      GoRoute(
        path: RoutePaths.starred,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const StarredMessagesScreen(),
      ),
      GoRoute(
        path: RoutePaths.pinned,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PinnedMessagesScreen(),
      ),
      GoRoute(
        path: RoutePaths.archived,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ArchivedMessagesScreen(),
      ),
      GoRoute(
        path: RoutePaths.deleted,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const DeletedMessagesScreen(),
      ),
      GoRoute(
        path: RoutePaths.category,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final typeString = state.pathParameters['type'];
          final category = CategoryTypeExtension.fromString(typeString);
          return CategoryMessagesScreen(category: category);
        },
      ),
      GoRoute(
        path: RoutePaths.messageDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MessageDetailScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.labelDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return LabelDetailScreen(labelId: id);
        },
      ),

      // Settings Sub-Routes
      GoRoute(
        path: RoutePaths.settingsGeneral,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const GeneralSettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.settingsOrganization,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OrganizationSettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.settingsNotifications,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsSettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.settingsPrivacy,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.settingsAppearance,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AppearanceSettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.settingsAbout,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AboutSettingsScreen(),
      ),

      // Primary Application Stateful Navigation Shell (4 Main Destinations)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ResponsiveScaffold(navigationShell: navigationShell);
        },
        branches: [
          // 1. Inbox Branch
          StatefulShellBranch(
            navigatorKey: inboxNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.inbox,
                builder: (context, state) => const InboxScreen(),
              ),
            ],
          ),

          // 2. Search Branch
          StatefulShellBranch(
            navigatorKey: searchNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.search,
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),

          // 3. Labels Branch
          StatefulShellBranch(
            navigatorKey: labelsNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.labels,
                builder: (context, state) => const LabelsScreen(),
              ),
            ],
          ),

          // 4. Settings Branch
          StatefulShellBranch(
            navigatorKey: settingsNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
