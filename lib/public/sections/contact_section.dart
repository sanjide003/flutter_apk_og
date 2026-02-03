import 'package:flutter/material.dart';

import 'section_card.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Contact',
      subtitle: 'Add address, phone, and map details.',
      icon: Icons.place,
    );
  }
}
