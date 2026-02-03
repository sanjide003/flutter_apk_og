import 'package:flutter/material.dart';

import 'section_card.dart';

class ManagementSection extends StatelessWidget {
  const ManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Management & Staff',
      subtitle: 'Showcase leadership and staff profiles here.',
      icon: Icons.people_alt,
    );
  }
}
