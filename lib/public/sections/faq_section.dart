import 'package:flutter/material.dart';

class FAQSection extends StatelessWidget {
  const FAQSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('FAQ & Enquiry', style: Theme.of(context).textTheme.titleLarge),
      subtitle: const Text('Add frequently asked questions and enquiry form.'),
    );
  }
}
