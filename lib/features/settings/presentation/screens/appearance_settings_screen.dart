import 'package:delmess/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_auto_outlined),
            title: const Text('System Default'),
            subtitle: const Text(
              'Automatically adapt to device light or dark mode',
            ),
            trailing: currentTheme == ThemeMode.system
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : const Icon(Icons.circle_outlined),
            onTap: () =>
                ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.light_mode_outlined),
            title: const Text('Light Mode'),
            subtitle: const Text('Clean, crisp white and pastel interface'),
            trailing: currentTheme == ThemeMode.light
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : const Icon(Icons.circle_outlined),
            onTap: () =>
                ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            subtitle: const Text(
              'Battery friendly deep slate and AMOLED palette',
            ),
            trailing: currentTheme == ThemeMode.dark
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : const Icon(Icons.circle_outlined),
            onTap: () =>
                ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}
