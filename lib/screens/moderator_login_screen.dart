// screens/moderator_login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/retro_button.dart' as retro;
import '../widgets/retro_panel.dart';
import 'moderator_dashboard_screen.dart';

class ModeratorLoginScreen extends StatefulWidget {
  const ModeratorLoginScreen({super.key});

  @override
  _ModeratorLoginScreenState createState() => _ModeratorLoginScreenState();
}

class _ModeratorLoginScreenState extends State<ModeratorLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Updated credentials: batman/ammar007
    if (username == 'batman' && password == 'ammar007') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ModeratorDashboardScreen(),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid username or password';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Moderator Login',
          style: GoogleFonts.vt323(fontSize: 20),
        ),
        backgroundColor: const Color(0xFFC0C0C0),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE0E0E0),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC0C0C0),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.security,
                          size: 48,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'MODERATOR ACCESS',
                          style: GoogleFonts.vt323(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Enter your credentials below',
                          style: GoogleFonts.vt323(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Login Form
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Username Field
                        Text(
                          'Username:',
                          style: GoogleFonts.vt323(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        RetroPanel(
                          type: RetroPanelType.sunken,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter username',
                            ),
                            style: GoogleFonts.vt323(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Password Field
                        Text(
                          'Password:',
                          style: GoogleFonts.vt323(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        RetroPanel(
                          type: RetroPanelType.sunken,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter password',
                            ),
                            style: GoogleFonts.vt323(fontSize: 16),
                            onSubmitted: (_) => _login(), // Allow login on Enter key
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Error Message
                        if (_errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDDDD),
                              border: Border.all(color: Colors.red, width: 1),
                            ),
                            child: Text(
                              _errorMessage,
                              style: GoogleFonts.vt323(
                                fontSize: 14,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        
                        // Login Button
                        retro.RetroButton(
                          onTap: _isLoading 
                              ? () {} // Empty function when loading
                              : () => _login(),
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Logging in...',
                                      style: GoogleFonts.vt323(fontSize: 16),
                                    ),
                                  ],
                                )
                              : Text(
                                  'LOGIN',
                                  style: GoogleFonts.vt323(fontSize: 16),
                                ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Updated demo credentials info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            border: Border.all(color: Colors.black54, width: 1),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Demo Credentials:',
                                style: GoogleFonts.vt323(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Username: batman',
                                style: GoogleFonts.vt323(fontSize: 12),
                              ),
                              Text(
                                'Password: ammar007',
                                style: GoogleFonts.vt323(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}
