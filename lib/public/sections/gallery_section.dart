import 'package:flutter/material.dart';

import 'section_card.dart';

class GallerySection extends StatelessWidget {
  const GallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Gallery',
      subtitle: 'Highlight campus photos and events.',
      icon: Icons.photo_library,
    );
  }
}
