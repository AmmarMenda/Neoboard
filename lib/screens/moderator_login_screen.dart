// lib/screens/moderator_login_screen.dart
import 'package:flutter/material.dart';
import '../widgets/retro_button.dart' as retro;
import '../widgets/retro_panel.dart';
import 'moderator_dashboard_screen.dart';
import '../widgets/leopard_app_bar.dart'; // Use the themed AppBar

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
    await Future.delayed(const Duration(seconds: 1));
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (username == 'batman' && password == 'ammar007') {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ModeratorDashboardScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Invalid username or password';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const LeopardAppBar(title: Text('Moderator Login')),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RetroPanel(
                  child: Column(
                    children: [
                      Icon(
                        Icons.security,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'MODERATOR ACCESS',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enter your credentials below',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                RetroPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        // *** THE FIX: Use onEditingComplete instead of onSubmitted ***
                        onEditingComplete: _isLoading ? null : _login,
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withOpacity(0.1),
                            border: Border.all(
                              color: theme.colorScheme.error.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      retro.RetroButton(
                        onTap: _isLoading ? null : _login,
                        child: _isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Logging in...'),
                                ],
                              )
                            : const Text('LOGIN'),
                      ),
                      const SizedBox(height: 24),
                      // *** THE FIX: Use a Container with decoration instead of a non-existent parameter ***
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Demo Credentials:',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Username: batman',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              'Password: ammar007',
                              style: theme.textTheme.bodySmall,
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
    );
  }
}
