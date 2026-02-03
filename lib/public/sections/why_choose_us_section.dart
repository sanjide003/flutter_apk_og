import 'package:flutter/material.dart';

import 'section_card.dart';

class WhyChooseUsSection extends StatelessWidget {
  const WhyChooseUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Why Choose Us',
      subtitle: 'Highlight the institution’s strengths.',
      icon: Icons.star,
    );
  }
}
