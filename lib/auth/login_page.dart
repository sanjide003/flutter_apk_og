import 'package:flutter/material.dart';

import '../config/routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentPasswordController = TextEditingController();
  final _staffPasswordController = TextEditingController();

  LoginRole _selectedRole = LoginRole.student;
  String? _selectedClass;
  String? _selectedStudent;
  String? _selectedStaff;

  final List<String> _classes = const [
    'Class 1 A',
    'Class 5 B',
    'Class 8 A',
    'Class 10 A',
  ];

  final Map<String, List<String>> _studentsByClass = const {
    'Class 1 A': ['Amina', 'David', 'Irfan'],
    'Class 5 B': ['Leena', 'Midhun', 'Rahul'],
    'Class 8 A': ['Akhil', 'Diya', 'Fathima'],
    'Class 10 A': ['Amal', 'Hana', 'Riya'],
  };

  final List<String> _staffNames = const [
    'Anju (Office)',
    'Manu (Accountant)',
    'Priya (Teacher)',
    'Sreelakshmi (Principal)',
  ];

  @override
  void dispose() {
    _studentPasswordController.dispose();
    _staffPasswordController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Choose Login Type',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _roleSelector(),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: _selectedRole == LoginRole.student
                ? _buildStudentForm(theme)
                : _buildStaffForm(theme),
          ),
          const SizedBox(height: 24),
          Text(
            'Admin access is available from the Management login path.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _roleSelector() {
    return SegmentedButton<LoginRole>(
      segments: const [
        ButtonSegment(
          value: LoginRole.student,
          label: Text('Student / Parent'),
          icon: Icon(Icons.school),
        ),
        ButtonSegment(
          value: LoginRole.staff,
          label: Text('Management / Staff'),
          icon: Icon(Icons.work),
        ),
      ],
      selected: {_selectedRole},
      onSelectionChanged: (roles) {
        setState(() {
          _selectedRole = roles.first;
        });
      },
    );
  }

  Widget _buildStudentForm(ThemeData theme) {
    final students = _studentsByClass[_selectedClass] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Student Login', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Select Class'),
          items: _classes
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          value: _selectedClass,
          onChanged: (value) {
            setState(() {
              _selectedClass = value;
              _selectedStudent = null;
            });
          },
          validator: (value) =>
              value == null ? 'Please select a class' : null,
        ),
        const SizedBox(height: 12),
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return students;
            }
            return students.where(
              (option) => option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()),
            );
          },
          onSelected: (value) => _selectedStudent = value,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            controller.text = _selectedStudent ?? controller.text;
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(labelText: 'Select Name'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Select a student' : null,
            );
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _studentPasswordController,
          decoration: const InputDecoration(
            labelText: 'Phone Number (Password)',
            helperText: 'Use the registered phone number',
          ),
          keyboardType: TextInputType.phone,
          validator: (value) =>
              value == null || value.isEmpty ? 'Enter phone number' : null,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _submitLogin(AppRoutes.student),
            child: const Text('Continue to Student Dashboard'),
          ),
        ),
      ],
    );
  }

  Widget _buildStaffForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Management / Staff Login', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return _staffNames;
            }
            return _staffNames.where(
              (option) => option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()),
            );
          },
          onSelected: (value) => _selectedStaff = value,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            controller.text = _selectedStaff ?? controller.text;
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(labelText: 'Search Name'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Select a staff member' : null,
            );
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _staffPasswordController,
          decoration: const InputDecoration(
            labelText: 'Custom Password',
            helperText: 'Use the admin assigned password',
          ),
          obscureText: true,
          validator: (value) =>
              value == null || value.isEmpty ? 'Enter password' : null,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _submitLogin(AppRoutes.staff),
            child: const Text('Continue to Staff Dashboard'),
          ),
        ),
      ],
    );
  }

  void _submitLogin(String route) {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pushNamed(context, route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form.')),
      );
    }
  }
}

enum LoginRole { student, staff }
