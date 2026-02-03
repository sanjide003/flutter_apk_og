import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('About', style: Theme.of(context).textTheme.titleLarge),
      subtitle: const Text('Add institution details, vision, and mission here.'),
    );
  }
}
