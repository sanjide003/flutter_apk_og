import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(32),
      color: theme.colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to the Institution',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text('Your digital gateway for students, staff, and management.'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onLoginTap,
            icon: const Icon(Icons.login),
            label: const Text('Start Login'),
          ),
        ],
      ),
    );
  }
}
