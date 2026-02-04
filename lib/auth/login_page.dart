import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  // State Management
  // 0: Selection Screen (Student vs Staff)
  // 1: Student Login Form
  // 2: Staff Login Form
  int _viewState = 0;
  bool _isLoading = false;

  // --- STUDENT CONTROLLERS ---
  String? _selectedClass;
  String? _selectedStudent;
  final TextEditingController _studentPhoneController = TextEditingController();
  List<String> _availableClasses = [];
  List<String> _availableStudents = [];

  // --- STAFF CONTROLLERS ---
  String? _selectedStaff;
  final TextEditingController _staffPassController = TextEditingController();
  List<String> _availableStaff = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    // പേജ് വരുമ്പോൾ തന്നെ ക്ലാസ്സുകളും സ്റ്റാഫിനെയും ലോഡ് ചെയ്യുന്നു
    final classes = await _authService.getClasses();
    final staff = await _authService.getStaffList();
    setState(() {
      _availableClasses = classes;
      _availableStaff = staff;
    });
  }

  // --- WIDGETS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login Portal"),
        leading: _viewState != 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _viewState = 0; // Back to selection
                    _selectedClass = null;
                    _selectedStudent = null;
                    _selectedStaff = null;
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context), // Close Login Page
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
      return const Center(child: CircularProgressIndicator());
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

  // VIEW 0: SELECTION SCREEN
  Widget _buildSelectionScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Who are you?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "Please select your role to continue",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 40),

        // Student Option
        _buildRoleCard(
          title: "Student / Parent",
          icon: Icons.school,
          color: Colors.blue.shade50,
          textColor: Colors.blue.shade900,
          onTap: () {
            setState(() => _viewState = 1);
          },
        ),

        const SizedBox(height: 20),

        // Staff Option
        _buildRoleCard(
          title: "Management / Staff",
          icon: Icons.badge,
          color: Colors.orange.shade50,
          textColor: Colors.orange.shade900,
          onTap: () {
            setState(() => _viewState = 2);
          },
        ),
      ],
    );
  }

  // VIEW 1: STUDENT LOGIN FORM
  Widget _buildStudentLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Student Login",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),

        // 1. Class Selection
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: "Select Class"),
          value: _selectedClass,
          items: _availableClasses.map((c) {
            return DropdownMenuItem(value: c, child: Text(c));
          }).toList(),
          onChanged: (val) async {
            setState(() {
              _selectedClass = val;
              _selectedStudent = null; // Reset student
              _isLoading = true;
            });
            // ക്ലാസ്സ് മാറുമ്പോൾ കുട്ടികളുടെ ലിസ്റ്റ് എടുക്കുന്നു
            final students = await _authService.getStudentsByClass(val!);
            setState(() {
              _availableStudents = students;
              _isLoading = false;
            });
          },
        ),
        const SizedBox(height: 20),

        // 2. Student Name Selection (Searchable)
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return const Iterable<String>.empty();
            }
            return _availableStudents.where((String option) {
              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            setState(() {
              _selectedStudent = selection;
            });
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              enabled: _selectedClass != null, // ക്ലാസ്സ് സെലക്ട് ചെയ്താലേ എനേബിൾ ആകൂ
              decoration: InputDecoration(
                labelText: "Student Name",
                hintText: _selectedClass == null 
                    ? "Select class first" 
                    : "Type to search your name",
                suffixIcon: const Icon(Icons.search),
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // 3. Password (Phone)
        TextField(
          controller: _studentPhoneController,
          decoration: const InputDecoration(
            labelText: "Registered Phone Number",
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          obscureText: true,
        ),
        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: _handleStudentLogin,
          child: const Text("LOGIN AS STUDENT"),
        ),
      ],
    );
  }

  // VIEW 2: STAFF LOGIN FORM
  Widget _buildStaffLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Staff / Management Login",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),

        // 1. Staff Name Search
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return const Iterable<String>.empty();
            }
            return _availableStaff.where((String option) {
              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            setState(() {
              _selectedStaff = selection;
            });
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              decoration: const InputDecoration(
                labelText: "Your Name",
                hintText: "Type to search...",
                suffixIcon: Icon(Icons.person_search),
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // 2. Password (Custom)
        TextField(
          controller: _staffPassController,
          decoration: const InputDecoration(
            labelText: "Password",
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: _handleStaffLogin,
          child: const Text("LOGIN AS STAFF"),
        ),
      ],
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildRoleCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: textColor),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
          ],
        ),
      ),
    );
  }

  // --- ACTIONS ---

  void _handleStudentLogin() async {
    if (_selectedClass == null || _selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Class and Name")),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Mock Login Call
    bool success = await _authService.loginStudent(
      _selectedClass!, 
      _selectedStudent!, 
      _studentPhoneController.text
    );

    setState(() => _isLoading = false);

    if (success) {
      // Navigate to Student Dashboard (Future)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Success! Welcome Student.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid Phone Number (Try 123456)")),
      );
    }
  }

  void _handleStaffLogin() async {
    if (_selectedStaff == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your Name")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Mock Login Call
    String? role = await _authService.loginStaff(
      _selectedStaff!, 
      _staffPassController.text
    );

    setState(() => _isLoading = false);

    if (role != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Success! Role: $role")),
      );
      // Navigate to Admin or Staff Dashboard based on role
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid Password (Try 'password')")),
      );
    }
  }
}
