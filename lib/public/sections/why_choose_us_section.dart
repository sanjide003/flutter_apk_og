import 'package:flutter/material.dart';

class WhyChooseUsSection extends StatelessWidget {
  const WhyChooseUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Why Choose Us', style: Theme.of(context).textTheme.titleLarge),
      subtitle: const Text('Highlight the institution’s strengths.'),
    );
  }
}
