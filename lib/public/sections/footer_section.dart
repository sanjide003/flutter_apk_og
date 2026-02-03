import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.primary,
      child: const Text(
        '© 2025 Institution Operating System',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
