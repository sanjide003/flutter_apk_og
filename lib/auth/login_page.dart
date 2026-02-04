import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  int _viewState = 0; // 0: Select, 1: Student, 2: Staff
  bool _isLoading = false;
  bool _isPasswordVisible = false; // പാസ്‌വേഡ് കാണാൻ

  // Inputs
  String? _selectedStaffName; // To store selected name
  final TextEditingController _staffPassController = TextEditingController();
  List<String> _availableStaff = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final staff = await _authService.getStaffNames();
    if (mounted) setState(() => _availableStaff = staff);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login Portal"),
        leading: IconButton(
          icon: Icon(_viewState == 0 ? Icons.close : Icons.arrow_back),
          onPressed: () {
            if (_viewState == 0) {
              Navigator.pop(context);
            } else {
              setState(() {
                _viewState = 0; // Back to selection
                _selectedStaffName = null;
                _staffPassController.clear();
              });
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _buildBody(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_viewState == 2) return _staffForm();
    if (_viewState == 1) return const Center(child: Text("Student Portal - Under Maintenance"));
    return _selectionScreen();
  }

  Widget _selectionScreen() {
    return Column(
      children: [
        const Text("Who are you?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 40),
        _roleCard("Management / Staff", Icons.badge, Colors.orange, () => setState(() => _viewState = 2)),
        const SizedBox(height: 20),
        _roleCard("Student / Parent", Icons.school, Colors.blue, () => setState(() => _viewState = 1)),
      ],
    );
  }

  Widget _staffForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Staff Login", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),

        // 1. NAME SEARCH INPUT (AUTOCOMPLETE)
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return _availableStaff.where((String option) {
              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            _selectedStaffName = selection;
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              decoration: const InputDecoration(
                labelText: "Type your Name",
                prefixIcon: Icon(Icons.person_search),
                hintText: "Search name...",
                border: OutlineInputBorder(),
              ),
            );
          },
        ),
        
        const SizedBox(height: 20),

        // 2. PASSWORD INPUT (WITH EYE ICON)
        TextField(
          controller: _staffPassController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: "Password",
            prefixIcon: const Icon(Icons.lock),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _attemptLogin,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
          child: const Text("LOGIN", style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  void _attemptLogin() async {
    if (_selectedStaffName == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please search and select a valid Name")));
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      String role = await _authService.loginStaff(_selectedStaffName!, _staffPassController.text);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (role == "admin") {
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (r) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Staff Page - Coming Soon")));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  Widget _roleCard(String title, IconData icon, Color color, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color)),
        child: Row(children: [Icon(icon, size: 30, color: color), const SizedBox(width: 20), Text(title, style: TextStyle(fontSize: 18, color: color))]),
      ),
    );
  }
}