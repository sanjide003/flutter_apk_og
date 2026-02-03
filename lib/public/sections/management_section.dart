import 'package:flutter/material.dart';

class ManagementSection extends StatelessWidget {
  const ManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Management & Staff', style: Theme.of(context).textTheme.titleLarge),
      subtitle: const Text('Showcase leadership and staff profiles here.'),
    );
  }
}
