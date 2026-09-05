/// Constants for all route paths in DelMess.
class RoutePaths {
  RoutePaths._();

  // Onboarding
  static const String welcome = '/welcome';
  static const String permissions = '/permissions';
  static const String import = '/import';

  // Core Navigation Tabs
  static const String inbox = '/inbox';
  static const String search = '/search';
  static const String labels = '/labels';
  static const String settings = '/settings';

  // Sub-routes & Folders
  static const String category = '/category/:type';
  static const String starred = '/starred';
  static const String pinned = '/pinned';
  static const String archived = '/archived';
  static const String deleted = '/deleted';
  static const String messageDetail = '/messages/:id';
  static const String labelDetail = '/labels/:id';

  // Settings Sub-sections
  static const String settingsGeneral = '/settings/general';
  static const String settingsOrganization = '/settings/organization';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsPrivacy = '/settings/privacy';
  static const String settingsAppearance = '/settings/appearance';
  static const String settingsAbout = '/settings/about';
}
