import 'package:flutter/material.dart';

class PublicPage extends StatelessWidget {
  const PublicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Institution Name"),
        actions: [
          // ലോഗിൻ ബട്ടൺ - പിന്നീട് നമ്മൾ Logic എഴുതും
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                // Navigate to Login Page
                // Navigator.pushNamed(context, '/login');
                print("Go to Login");
              },
              child: const Text("Login"),
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              "Welcome to Institution OS",
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 10),
            const Text("Public Page Content Loading..."),
          ],
        ),
      ),
    );
  }
}
