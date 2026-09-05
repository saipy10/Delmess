import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/constants/app_strings.dart';
import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/routing/route_paths.dart';
import 'package:delmess/core/widgets/app_buttons.dart';
import 'package:delmess/features/onboarding/presentation/widgets/feature_bullet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Welcome onboarding screen explaining DelMess value proposition.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // App Logo / Hero Icon
              Container(
                padding: const EdgeInsets.all(AppDimensions.space20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread,
                  size: AppDimensions.iconXl,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppDimensions.space24),

              // Title & Subtitle
              Text(
                AppStrings.welcomeTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                AppStrings.welcomeSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.space32),

              // Feature Highlights
              FeatureBullet(
                icon: CategoryType.transactional.icon,
                iconColor: CategoryType.transactional.getColor(context),
                title: 'Smart Indian SMS Categorization',
                description:
                    'Effortlessly separates bank alerts, food deliveries, promos, and government notices.',
              ),
              const SizedBox(height: AppDimensions.space16),
              FeatureBullet(
                icon: Icons.key_outlined,
                iconColor: theme.colorScheme.secondary,
                title: 'Instant OTP Extraction',
                description:
                    'One-tap copy for authentication codes and delivery pins right from your notification.',
              ),
              const SizedBox(height: AppDimensions.space16),
              const FeatureBullet(
                icon: Icons.shield_outlined,
                iconColor: Colors.teal,
                title: '100% On-Device & Private',
                description:
                    'All categorization happens on your device. Zero cloud sync or message tracking.',
              ),

              const Spacer(),

              // Get Started CTA Button
              PrimaryButton(
                text: AppStrings.getStarted,
                width: double.infinity,
                icon: Icons.arrow_forward,
                onPressed: () {
                  context.push(RoutePaths.permissions);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
