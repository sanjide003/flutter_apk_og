import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  // State
  int _viewState = 0; // 0: Select, 1: Student, 2: Staff
  bool _isLoading = false;

  // Student Controllers
  String? _selectedClass;
  String? _selectedStudent;
  final TextEditingController _studentPhoneController = TextEditingController();
  List<String> _availableClasses = [];
  List<String> _availableStudents = [];

  // Staff Controllers
  String? _selectedStaff;
  final TextEditingController _staffPassController = TextEditingController();
  List<String> _availableStaff = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final classes = await _authService.getClasses();
    final staff = await _authService.getStaffList();
    if (mounted) {
      setState(() {
        _availableClasses = classes;
        _availableStaff = staff;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login Portal"),
        leading: _viewState != 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _viewState = 0;
                  _isLoading = false;
                }),
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _buildCurrentView(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Authenticating..."),
          ],
        ),
      );
    }
    switch (_viewState) {
      case 1:
        return _buildStudentLoginForm();
      case 2:
        return _buildStaffLoginForm();
      case 0:
      default:
        return _buildSelectionScreen();
    }
  }

  Widget _buildSelectionScreen() {
    return Column(
      children: [
        const Text("Who are you?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("Select your role to continue", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 40),
        _buildRoleCard("Student / Parent", Icons.school, Colors.blue.shade50, Colors.blue.shade900, () => setState(() => _viewState = 1)),
        const SizedBox(height: 20),
        _buildRoleCard("Management / Staff", Icons.badge, Colors.orange.shade50, Colors.orange.shade900, () => setState(() => _viewState = 2)),
      ],
    );
  }

  Widget _buildStudentLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Student Login", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: "Select Class"),
          value: _selectedClass,
          items: _availableClasses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (val) async {
            setState(() {
              _selectedClass = val;
              _selectedStudent = null;
              _isLoading = true;
            });
            final students = await _authService.getStudentsByClass(val!);
            setState(() {
              _availableStudents = students;
              _isLoading = false;
            });
          },
        ),
        const SizedBox(height: 20),
        Autocomplete<String>(
          optionsBuilder: (v) => v.text.isEmpty ? const Iterable<String>.empty() : _availableStudents.where((s) => s.toLowerCase().contains(v.text.toLowerCase())),
          onSelected: (s) => setState(() => _selectedStudent = s),
          fieldViewBuilder: (ctx, ctrl, focus, onEdit) => TextField(
            controller: ctrl, focusNode: focus, onEditingComplete: onEdit,
            enabled: _selectedClass != null,
            decoration: InputDecoration(labelText: "Student Name", hintText: _selectedClass == null ? "Select class first" : "Search name", suffixIcon: const Icon(Icons.search)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(controller: _studentPhoneController, decoration: const InputDecoration(labelText: "Phone Number", prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone, obscureText: true),
        const SizedBox(height: 30),
        ElevatedButton(onPressed: _handleStudentLogin, child: const Text("LOGIN AS STUDENT")),
      ],
    );
  }

  Widget _buildStaffLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Staff / Management Login", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Autocomplete<String>(
          optionsBuilder: (v) => v.text.isEmpty ? const Iterable<String>.empty() : _availableStaff.where((s) => s.toLowerCase().contains(v.text.toLowerCase())),
          onSelected: (s) => setState(() => _selectedStaff = s),
          fieldViewBuilder: (ctx, ctrl, focus, onEdit) => TextField(
            controller: ctrl, focusNode: focus, onEditingComplete: onEdit,
            decoration: const InputDecoration(labelText: "Your Name", hintText: "Search...", suffixIcon: Icon(Icons.person_search)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(controller: _staffPassController, decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock)), obscureText: true),
        const SizedBox(height: 30),
        ElevatedButton(onPressed: _handleStaffLogin, child: const Text("LOGIN AS STAFF")),
      ],
    );
  }

  Widget _buildRoleCard(String title, IconData icon, Color color, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), border: Border.all(color: textColor.withOpacity(0.3))),
        child: Row(children: [Icon(icon, size: 40, color: textColor), const SizedBox(width: 20), Expanded(child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor))), Icon(Icons.arrow_forward_ios, size: 16, color: textColor)]),
      ),
    );
  }

  void _handleStudentLogin() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Student Dashboard Coming Soon!")));
  }

  void _handleStaffLogin() async {
    if (_selectedStaff == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select your Name")));
      return;
    }
    
    // കീബോർഡ് താഴേക്ക് ഇറക്കുന്നു
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);
    
    try {
      // Login Call
      String role = await _authService.loginStaff(_selectedStaff!, _staffPassController.text);
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (role == "admin") {
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
      } else if (role == "staff") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Staff Dashboard Coming Soon!")));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // എറർ മെസ്സേജ് കൃത്യമായി കാണിക്കുന്നു
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Failed: ${e.toString().replaceAll('Exception:', '')}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
