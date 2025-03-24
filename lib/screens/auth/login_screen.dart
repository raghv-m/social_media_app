import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final Function(String, String) onLogin;
  final bool isLoading;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Padding(
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => onLogin(
                        emailController.text,
                        passwordController.text,
                      ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }
} 