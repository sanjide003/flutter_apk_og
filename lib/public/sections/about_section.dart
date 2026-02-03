import 'package:flutter/material.dart';

import 'section_card.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'About',
      subtitle: 'Add institution details, vision, and mission here.',
      icon: Icons.info,
    );
  }
}
