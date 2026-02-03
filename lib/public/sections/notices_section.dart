import 'package:flutter/material.dart';

class NoticesSection extends StatelessWidget {
  const NoticesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Notices', style: Theme.of(context).textTheme.titleLarge),
      subtitle: const Text('Publish public announcements and updates.'),
    );
  }
}
