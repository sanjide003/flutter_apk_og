import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  int _viewState = 0; 
  bool _isLoading = false;

  // Staff Login Variables
  String? _selectedStaff;
  final TextEditingController _staffPassController = TextEditingController();
  List<String> _availableStaff = [];

  // Student Login Variables
  String? _selectedClass;
  // (Student ഭാഗം ഇപ്പോൾ ശൂന്യമാണ് കാരണം ഡാറ്റ ഇല്ല)

  @override
  void initState() {
    super.initState();
    _loadRealData();
  }

  // ഫയർബേസിൽ നിന്ന് ലിസ്റ്റ് എടുക്കുന്നു
  void _loadRealData() async {
    setState(() => _isLoading = true);
    try {
      final staff = await _authService.getStaffList();
      if (mounted) {
        setState(() {
          _availableStaff = staff;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
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
                _viewState = 0;
                _selectedStaff = null;
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
    if (_isLoading) {
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text("Loading Data..."),
        ],
      );
    }
    if (_viewState == 2) return _staffForm();
    if (_viewState == 1) return const Center(child: Text("No Students Added Yet"));
    return _selectionScreen();
  }

  Widget _selectionScreen() {
    return Column(
      children: [
        const Text("Fee edusy Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
        const Text("Staff Login", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        
        // Staff Name Dropdown (Real Data)
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: "Select Name"),
          value: _selectedStaff,
          items: _availableStaff.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => _selectedStaff = val),
          hint: const Text("Select Name"),
        ),
        
        const SizedBox(height: 15),
        TextField(
          controller: _staffPassController,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Password"),
        ),
        
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _attemptLogin,
          child: const Text("Login"),
        ),
      ],
    );
  }

  void _attemptLogin() async {
    if (_selectedStaff == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select a Name")));
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Real Login Call
      String role = await _authService.loginStaff(_selectedStaff!, _staffPassController.text);
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (role == "admin") {
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Staff Page Not Ready")));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed: ${e.toString()}"), backgroundColor: Colors.red));
    }
  }

  Widget _roleCard(String title, IconData icon, Color color, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), 
          borderRadius: BorderRadius.circular(10), 
          border: Border.all(color: color)
        ),
        child: Row(children: [Icon(icon, size: 30, color: color), const SizedBox(width: 20), Text(title, style: TextStyle(fontSize: 18, color: color))]),
      ),
    );
  }
}
