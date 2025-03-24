import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  final Function(String, String, String, String, String, DateTime) onSignup;
  final bool isLoading;

  const SignupScreen({
    super.key,
    required this.onSignup,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final usernameController = TextEditingController();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Date of Birth'),
            subtitle: Text(
              DateFormat('MMM dd, yyyy').format(selectedDate),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != selectedDate) {
                selectedDate = picked;
              }
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => onSignup(
                        emailController.text,
                        passwordController.text,
                        usernameController.text,
                        nameController.text,
                        phoneController.text,
                        selectedDate,
                      ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Sign Up'),
            ),
          ),
        ],
      ),
    );
  }
} 