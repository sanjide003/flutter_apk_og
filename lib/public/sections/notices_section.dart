import 'package:flutter/material.dart';

import 'section_card.dart';

class NoticesSection extends StatelessWidget {
  const NoticesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Notices',
      subtitle: 'Publish public announcements and updates.',
      icon: Icons.campaign,
    );
  }
}
