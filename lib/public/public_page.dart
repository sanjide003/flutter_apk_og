import 'package:flutter/material.dart';

import '../auth/login_page.dart';
import 'sections/about_section.dart';
import 'sections/academic_section.dart';
import 'sections/contact_section.dart';
import 'sections/cta_section.dart';
import 'sections/faq_section.dart';
import 'sections/footer_section.dart';
import 'sections/gallery_section.dart';
import 'sections/header_section.dart';
import 'sections/hero_section.dart';
import 'sections/management_section.dart';
import 'sections/notices_section.dart';
import 'sections/why_choose_us_section.dart';

class PublicPage extends StatelessWidget {
  const PublicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          HeaderSection(onLoginTap: () => _openLogin(context)),
          HeroSection(onLoginTap: () => _openLogin(context)),
          AboutSection(),
          ManagementSection(),
          AcademicSection(),
          GallerySection(),
          NoticesSection(),
          WhyChooseUsSection(),
          FAQSection(),
          CTASection(onLoginTap: () => _openLogin(context)),
          ContactSection(),
          FooterSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openLogin(context),
        label: const Text('Login'),
        icon: const Icon(Icons.login),
      ),
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}
