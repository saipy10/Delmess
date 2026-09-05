import 'package:flutter/material.dart';

class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  bool _autoBackup = true;
  final String _selectedSim = 'All SIMs';
  final String _language = 'English (India)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Local Auto-Backup'),
            subtitle: const Text(
              'Regularly backup message classifications locally on device',
            ),
            value: _autoBackup,
            onChanged: (val) => setState(() => _autoBackup = val),
          ),
          const Divider(),
          ListTile(
            title: const Text('Active SIM Card Filter'),
            subtitle: Text(_selectedSim),
            trailing: const Icon(Icons.sim_card_outlined),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Dual-SIM configuration will be connected in Phase 2.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(_language),
            trailing: const Icon(Icons.language_outlined),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
