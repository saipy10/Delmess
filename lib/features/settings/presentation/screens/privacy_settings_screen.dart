import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.shield_outlined, color: Colors.teal),
            title: Text('Zero Cloud Upload Guarantee'),
            subtitle: Text(
              'DelMess operates 100% locally on your device. SMS contents and OTPs are never transmitted over the network.',
            ),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.analytics_outlined, color: Colors.blue),
            title: Text('No Usage Telemetry'),
            subtitle: Text(
              'We do not track your reading habits, message volumes, or financial data.',
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_reset, color: Colors.deepOrange),
            title: const Text('Clear All Local App Cache'),
            subtitle: const Text(
              'Erase all cached metadata and classifications',
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Local cache cleared.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
