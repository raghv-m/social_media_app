import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_app/services/chattr_backend.dart';
import 'package:social_media_app/providers/theme_provider.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Controllers for login
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Controllers for signup
  final _signupNameController = TextEditingController();
  final _signupPhoneController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupPhoneController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    super.dispose();
  }

  void _toggleView() {
    setState(() {
      _isLogin = !_isLogin;
      _animationController.reset();
      _animationController.forward();
    });
  }

  Future<void> _handleLogin() async {
    if (_loginEmailController.text.isEmpty || _loginPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Provider.of<ChattrBackend>(context, listen: false).login(
        _loginEmailController.text,
        _loginPasswordController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignup() async {
    if (_signupNameController.text.isEmpty ||
        _signupPhoneController.text.isEmpty ||
        _signupEmailController.text.isEmpty ||
        _signupPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Provider.of<ChattrBackend>(context, listen: false).signUp(
        _signupEmailController.text,
        _signupPasswordController.text,
        _signupNameController.text,
        _signupNameController.text,
        _signupPhoneController.text,
        DateTime.now(),
      );
      if (mounted) {
        setState(() => _isLogin = true);
        _animationController.reset();
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = context.watch<ThemeProvider>().currentColor.color;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'CHATTR',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 40,
                        color: themeColor,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: themeColor.withOpacity(0.5),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect, Share, and Explore',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        if (_isLogin) ...[
                          _buildTextField(
                            controller: _loginEmailController,
                            hint: 'Email or Username',
                            icon: Icons.person_outline,
                            themeColor: themeColor,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _loginPasswordController,
                            hint: 'Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            themeColor: themeColor,
                          ),
                          const SizedBox(height: 24),
                          _buildButton(
                            text: 'Login',
                            onPressed: _handleLogin,
                            themeColor: themeColor,
                          ),
                        ] else ...[
                          _buildTextField(
                            controller: _signupNameController,
                            hint: 'Name',
                            icon: Icons.person_outline,
                            themeColor: themeColor,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _signupPhoneController,
                            hint: 'Phone Number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            themeColor: themeColor,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _signupEmailController,
                            hint: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            themeColor: themeColor,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _signupPasswordController,
                            hint: 'Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            themeColor: themeColor,
                          ),
                          const SizedBox(height: 24),
                          _buildButton(
                            text: 'Sign Up',
                            onPressed: _handleSignup,
                            themeColor: themeColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Toggle Button
                  TextButton(
                    onPressed: _toggleView,
                    child: Text(
                      _isLogin
                          ? 'Don\'t have an account? Sign Up'
                          : 'Already have an account? Login',
                      style: TextStyle(
                        color: themeColor,
                        fontSize: 14,
                        fontFamily: GoogleFonts.poppins().fontFamily,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    required Color themeColor,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: Colors.white,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        prefixIcon: Icon(icon, color: themeColor),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      obscureText: isPassword,
      keyboardType: keyboardType,
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required Color themeColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
      ),
    );
  }
} 