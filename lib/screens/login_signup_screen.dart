import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  LoginSignupScreenState createState() => LoginSignupScreenState();
}

class LoginSignupScreenState extends State<LoginSignupScreen> {
  bool _isSignup = false;
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailOrUsernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  DateTime? _dateOfBirth;

  String? _usernameError;
  String? _generalError;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      if (_isSignup) {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailOrUsernameController.text,
          password: _passwordController.text,
        );
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailOrUsernameController.text,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'username': _usernameController.text,
          'dateOfBirth': _dateOfBirth!.toIso8601String(),
        });
      } else {
        await _auth.signInWithEmailAndPassword(
          email: _emailOrUsernameController.text,
          password: _passwordController.text,
        );
      }
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _generalError = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AnimatedLogo(), // Pixelated animated logo
              const SizedBox(height: 10),
              Text(
                "Connect, Share, and Explore",
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  color: Colors.white70,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Container(
                  key: ValueKey<bool>(_isSignup),
                  padding: const EdgeInsets.all(20.0),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_isSignup)
                          _buildTextField(
                            controller: _nameController,
                            label: "Name",
                            icon: Icons.person,
                          ),
                        if (_isSignup) const SizedBox(height: 10),
                        if (_isSignup)
                          _buildTextField(
                            controller: _phoneController,
                            label: "Phone Number",
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                        if (_isSignup) const SizedBox(height: 10),
                        _buildTextField(
                          controller: _emailOrUsernameController,
                          label: _isSignup ? "Email" : "Email or Username",
                          icon: _isSignup ? Icons.email : Icons.person,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _passwordController,
                          label: "Password",
                          icon: Icons.lock,
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: _buttonStyle(),
                          child: Text(
                            _isSignup ? "Sign Up" : "Login",
                            style: GoogleFonts.roboto(fontSize: 16, color: const Color.fromARGB(255, 15, 15, 246)),
                          
                          ),
                        ),
                        if (_generalError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              _generalError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignup = !_isSignup;
                    _generalError = null;
                  });
                },
                child: Text(
                  _isSignup
                      ? "Already have an account? Login"
                      : "Don't have an account? Sign Up",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.roboto(fontSize: 16, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.roboto(fontSize: 16, color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? '$label is required' : null,
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 180, 180, 180),
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with TickerProviderStateMixin {
  List<AnimationController>? _controllers;
  List<Animation<double>>? _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      )..forward();
    });

    _animations = _controllers!.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    for (int i = 1; i < _controllers!.length; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        _controllers![i].forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return FadeTransition(
          opacity: _animations![index],
          child: Text(
            "CHATTR"[index],
            style: GoogleFonts.pressStart2p(fontSize: 42, color: Colors.white),
          ),
        );
      }),
    );
  }
}
