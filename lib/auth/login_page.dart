import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../student/student_page.dart'; // To navigate to student page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  bool _isStudentLogin = true; // Toggle between Student & Staff
  bool _isLoading = false;
  bool _obscurePass = true;

  // Student Controllers
  String? _selectedClass;
  Map<String, dynamic>? _selectedStudent;
  final TextEditingController _studentPassCtrl = TextEditingController();
  List<Map<String, dynamic>> _classStudents = [];

  // Staff Controllers
  final TextEditingController _staffIdCtrl = TextEditingController();
  final TextEditingController _staffPassCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                    child: const Icon(Icons.school, size: 50, color: Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isStudentLogin ? "Student Portal" : "Staff / Admin Portal",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isStudentLogin ? "Login to view your details" : "Login to manage operations",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // LOGIN FORMS
                  if (_isLoading) 
                    const CircularProgressIndicator()
                  else if (_isStudentLogin) 
                    _buildStudentForm()
                  else 
                    _buildStaffForm(),

                  const SizedBox(height: 30),
                  
                  // TOGGLE LINK
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isStudentLogin = !_isStudentLogin;
                        _clearForms();
                      });
                    },
                    child: Text.rich(
                      TextSpan(
                        text: _isStudentLogin ? "Are you a Staff/Management? " : "Are you a Student? ",
                        style: const TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: "Click Here",
                            style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _clearForms() {
    _selectedClass = null;
    _selectedStudent = null;
    _studentPassCtrl.clear();
    _staffIdCtrl.clear();
    _staffPassCtrl.clear();
    _classStudents = [];
  }

  // --- STUDENT FORM ---
  Widget _buildStudentForm() {
    return Column(
      children: [
        // 1. CLASS DROPDOWN
        StreamBuilder(
          stream: _authService.getActiveClasses(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            var classes = snapshot.data!.docs.map((d) => d['name'].toString()).toList();
            
            return DropdownButtonFormField<String>(
              value: _selectedClass,
              decoration: const InputDecoration(labelText: "Select Class", border: OutlineInputBorder(), prefixIcon: Icon(Icons.class_)),
              items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) async {
                setState(() {
                  _selectedClass = val;
                  _selectedStudent = null;
                  _isLoading = true;
                });
                var students = await _authService.getStudentsForLogin(val!);
                setState(() {
                  _classStudents = students;
                  _isLoading = false;
                });
              },
            );
          },
        ),
        const SizedBox(height: 15),

        // 2. NAME AUTO-SUGGEST (Dropdown logic for simplicity or Autocomplete)
        DropdownButtonFormField<Map<String, dynamic>>(
          value: _selectedStudent,
          decoration: const InputDecoration(labelText: "Select Your Name", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
          hint: const Text("Choose Name"),
          items: _classStudents.map((s) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: s,
              child: Text(s['name']),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedStudent = val),
        ),
        const SizedBox(height: 15),

        // 3. PHONE / PASSWORD
        TextField(
          controller: _studentPassCtrl,
          keyboardType: TextInputType.phone,
          obscureText: _obscurePass,
          decoration: InputDecoration(
            labelText: "Phone Number (Password)",
            prefixIcon: const Icon(Icons.phone),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _handleStudentLogin,
            child: const Text("LOGIN"),
          ),
        ),
      ],
    );
  }

  // --- STAFF FORM ---
  Widget _buildStaffForm() {
    return Column(
      children: [
        TextField(
          controller: _staffIdCtrl,
          decoration: const InputDecoration(labelText: "Username / Gmail", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _staffPassCtrl,
          obscureText: _obscurePass,
          decoration: InputDecoration(
            labelText: "Password",
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _handleStaffLogin,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("LOGIN AS STAFF/ADMIN"),
          ),
        ),
      ],
    );
  }

  // --- ACTIONS ---

  void _handleStudentLogin() async {
    if (_selectedStudent == null || _studentPassCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select Name and enter Phone Number")));
      return;
    }
    setState(() => _isLoading = true);
    
    bool isValid = await _authService.verifyStudentLogin(_selectedStudent!['id'], _studentPassCtrl.text);
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (isValid) {
      // Navigate to Student Dashboard
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => StudentPage(
          studentId: _selectedStudent!['id'], 
          studentName: _selectedStudent!['name'])
        )
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Phone Number"), backgroundColor: Colors.red));
    }
  }

  void _handleStaffLogin() async {
    if (_staffIdCtrl.text.isEmpty || _staffPassCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      String role = await _authService.loginStaff(_staffIdCtrl.text, _staffPassCtrl.text);
      if (!mounted) return;
      
      if (role == "admin") {
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (r) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/staff', (r) => false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed: ${e.toString()}"), backgroundColor: Colors.red));
    }
  }
}