// widgets/admin_access_widget.dart
import 'package:flutter/material.dart';
import 'package:aplikasitest1/view/admin_page.dart';

class AdminAccessWidget extends StatelessWidget {
  const AdminAccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: Colors.red,
      onPressed: () => _showAdminDialog(context),
      child: const Icon(Icons.admin_panel_settings, color: Colors.white),
    );
  }

  void _showAdminDialog(BuildContext context) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Access'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan password admin untuk mengakses panel admin:'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Admin',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              passwordController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (passwordController.text == 'admin123') {
                passwordController.dispose();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminPanel(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password admin salah'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
