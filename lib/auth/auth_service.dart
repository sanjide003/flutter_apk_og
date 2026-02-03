class AuthService {
  const AuthService();

  bool validateStudentPassword({required String phonePassword}) {
    return phonePassword.trim().isNotEmpty;
  }

  bool validateStaffPassword({required String customPassword}) {
    return customPassword.trim().isNotEmpty;
  }
}
