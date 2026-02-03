import 'package:flutter/material.dart';

class CTASection extends StatelessWidget {
  const CTASection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ready to login?', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Students, staff, and management can sign in here.'),
        ],
      ),
    );
  }
}
