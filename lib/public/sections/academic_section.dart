import 'package:flutter/material.dart';

class AcademicSection extends StatelessWidget {
  const AcademicSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Academic', style: Theme.of(context).textTheme.titleLarge),
      subtitle: const Text('List courses, classes, and academic programs.'),
    );
  }
}
