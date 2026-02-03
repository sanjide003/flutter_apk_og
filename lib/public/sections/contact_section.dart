import 'package:flutter/material.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Contact', style: Theme.of(context).textTheme.titleLarge),
      subtitle: const Text('Add address, phone, and map details.'),
    );
  }
}
