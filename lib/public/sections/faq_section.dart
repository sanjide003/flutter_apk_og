import 'package:flutter/material.dart';

import 'section_card.dart';

class FAQSection extends StatelessWidget {
  const FAQSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'FAQ & Enquiry',
      subtitle: 'Add frequently asked questions and enquiry form.',
      icon: Icons.help_outline,
    );
  }
}
