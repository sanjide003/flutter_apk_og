import 'package:flutter/material.dart';

class CTASection extends StatelessWidget {
  const CTASection({super.key, required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      color: theme.colorScheme.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ready to login?', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Students, staff, and management can sign in here.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onLoginTap,
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }
}
