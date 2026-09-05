import 'package:flutter/material.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _enableNotifications = true;
  bool _otpQuickCopyAction = true;
  bool _mutePromotions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Allow Notifications'),
            subtitle: const Text('Receive alerts for incoming SMS messages'),
            value: _enableNotifications,
            onChanged: (val) => setState(() => _enableNotifications = val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('OTP "Copy Code" Quick Action'),
            subtitle: const Text(
              'Show a direct "Copy OTP" button in banner notifications',
            ),
            value: _otpQuickCopyAction,
            onChanged: (val) => setState(() => _otpQuickCopyAction = val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Mute Promotional Alerts'),
            subtitle: const Text(
              'Deliver promotional and marketing SMS silently without sound',
            ),
            value: _mutePromotions,
            onChanged: (val) => setState(() => _mutePromotions = val),
          ),
        ],
      ),
    );
  }
}
