import 'package:flutter/material.dart';

class OrganizationSettingsScreen extends StatefulWidget {
  const OrganizationSettingsScreen({super.key});

  @override
  State<OrganizationSettingsScreen> createState() =>
      _OrganizationSettingsScreenState();
}

class _OrganizationSettingsScreenState
    extends State<OrganizationSettingsScreen> {
  bool _autoDeleteOldOtps = true;
  bool _groupBankTransactions = true;
  bool _blockPromotionalSpam = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organization Rules')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Auto-delete expired OTPs'),
            subtitle: const Text(
              'Automatically move OTP messages to trash after 3 days',
            ),
            value: _autoDeleteOldOtps,
            onChanged: (val) => setState(() => _autoDeleteOldOtps = val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Group Bank Transactions'),
            subtitle: const Text(
              'Group debits and credits by bank sender into financial summaries',
            ),
            value: _groupBankTransactions,
            onChanged: (val) => setState(() => _groupBankTransactions = val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Spam Guard Filter'),
            subtitle: const Text(
              'Mute and quarantine aggressive promotional senders',
            ),
            value: _blockPromotionalSpam,
            onChanged: (val) => setState(() => _blockPromotionalSpam = val),
          ),
          const Divider(),
          ListTile(
            title: const Text('Custom Classification Rules'),
            subtitle: const Text(
              'Define custom keyword rules for sender categories',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Custom rule editor will be enabled in future phase.',
                  ),
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
