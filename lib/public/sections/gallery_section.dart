import 'package:flutter/material.dart';

class GallerySection extends StatelessWidget {
  const GallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Gallery', style: Theme.of(context).textTheme.titleLarge),
      subtitle: const Text('Highlight campus photos and events.'),
    );
  }
}
