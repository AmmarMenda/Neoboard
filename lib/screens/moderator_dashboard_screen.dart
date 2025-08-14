// screens/moderator_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/retro_button.dart' as retro;
import 'board_list_screen.dart';
import 'moderator_thread_management_screen.dart';
import 'moderator_report_screen.dart'; // Make sure this import exists

class ModeratorDashboardScreen extends StatelessWidget {
  const ModeratorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Moderator Dashboard',
          style: GoogleFonts.vt323(fontSize: 20),
        ),
        backgroundColor: const Color(0xFFC0C0C0),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const BoardListScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE0E0E0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Welcome Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFC0C0C0),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 48,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'MODERATOR PANEL',
                      style: GoogleFonts.vt323(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage threads, posts, and users',
                      style: GoogleFonts.vt323(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Buttons Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _ModeratorActionCard(
                      icon: Icons.forum,
                      title: 'Manage Threads',
                      description: 'View and delete threads',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ModeratorThreadManagementScreen(),
                          ),
                        );
                      },
                    ),
                    _ModeratorActionCard(
                      icon: Icons.report,
                      title: 'Reports',
                      description: 'Handle user reports',
                      onTap: () {
                        // This is the navigation that should work
                        print('Attempting to navigate to reports screen...'); // Debug print
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ModeratorReportsScreen(),
                          ),
                        );
                      },
                    ),
                    _ModeratorActionCard(
                      icon: Icons.people,
                      title: 'User Management',
                      description: 'Manage user accounts',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User management coming soon!')),
                        );
                      },
                    ),
                    _ModeratorActionCard(
                      icon: Icons.settings,
                      title: 'Board Settings',
                      description: 'Configure board settings',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Settings coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Back to Home Button
              const SizedBox(height: 16),
              retro.RetroButton(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const BoardListScreen()),
                    (route) => false,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.home, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Back to Home',
                      style: GoogleFonts.vt323(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeratorActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ModeratorActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.vt323(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.vt323(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
