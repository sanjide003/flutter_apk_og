import 'package:flutter/material.dart';

import '../config/routes.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Login Type',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _LoginOptionCard(
              title: 'Student / Parent',
              description: 'Select class → select name → enter phone number',
              onTap: () => Navigator.pushNamed(context, AppRoutes.student),
            ),
            const SizedBox(height: 12),
            _LoginOptionCard(
              title: 'Management / Staff',
              description: 'Search name → enter admin-set password',
              onTap: () => Navigator.pushNamed(context, AppRoutes.staff),
            ),
            const SizedBox(height: 24),
            Text(
              'Admin access is available from the Management login path.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginOptionCard extends StatelessWidget {
  const _LoginOptionCard({
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.login, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(description, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
