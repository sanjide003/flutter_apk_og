import 'package:flutter/material.dart';

import 'section_card.dart';

class AcademicSection extends StatelessWidget {
  const AcademicSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Academic',
      subtitle: 'List courses, classes, and academic programs.',
      icon: Icons.menu_book,
    );
  }
}
