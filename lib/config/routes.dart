import 'package:flutter/material.dart';

import '../admin/admin_dashboard.dart';
import '../auth/login_page.dart';
import '../public/public_page.dart';
import '../staff/staff_dashboard.dart';
import '../student/student_dashboard.dart';

class AppRoutes {
  static const publicHome = '/';
  static const login = '/login';
  static const admin = '/admin';
  static const staff = '/staff';
  static const student = '/student';
}

Map<String, WidgetBuilder> buildRoutes() {
  return {
    AppRoutes.publicHome: (_) => const PublicPage(),
    AppRoutes.login: (_) => const LoginPage(),
    AppRoutes.admin: (_) => const AdminDashboard(),
    AppRoutes.staff: (_) => const StaffDashboard(),
    AppRoutes.student: (_) => const StudentDashboard(),
  };
}
