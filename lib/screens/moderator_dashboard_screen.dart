// screens/moderator_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/retro_button.dart' as retro;
import '../utils/responsive_helper.dart';
import 'board_list_screen.dart';
import 'moderator_thread_management_screen.dart';
import 'moderator_report_screen.dart';

class ModeratorDashboardScreen extends StatelessWidget {
  const ModeratorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Moderator Dashboard',
          style: GoogleFonts.vt323(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
          ),
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
          padding: ResponsiveHelper.getResponsivePadding(context),
          child: Column(
            children: [
              // Welcome Header
              Container(
                width: double.infinity,
                padding: ResponsiveHelper.getResponsivePadding(context),
                decoration: BoxDecoration(
                  color: const Color(0xFFC0C0C0),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: ResponsiveHelper.isSmallScreen(context) ? 36 : 48,
                      color: Colors.black,
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                    Text(
                      'MODERATOR PANEL',
                      style: GoogleFonts.vt323(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage threads, posts, and users',
                      style: GoogleFonts.vt323(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 24)),
              
              // Action Buttons Grid - Responsive
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount;
                    double childAspectRatio;
                    
                    if (constraints.maxWidth < 600) {
                      crossAxisCount = 1; // Single column on small screens
                      childAspectRatio = 3.0; // Wider cards on small screens
                    } else if (constraints.maxWidth < 900) {
                      crossAxisCount = 2; // Two columns on medium screens
                      childAspectRatio = 1.5;
                    } else {
                      crossAxisCount = 2; // Two columns on large screens
                      childAspectRatio = 1.2;
                    }

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 16),
                      mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 16),
                      childAspectRatio: childAspectRatio,
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
                    );
                  },
                ),
              ),
              
              // Back to Home Button
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 16)),
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
                    Icon(
                      Icons.home, 
                      size: ResponsiveHelper.isSmallScreen(context) ? 18 : 20,
                    ),
                    SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                    Text(
                      'Back to Home',
                      style: GoogleFonts.vt323(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                      ),
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
        padding: ResponsiveHelper.getResponsivePadding(context),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: ResponsiveHelper.isSmallScreen(context) ? 28 : 36,
              color: Colors.black,
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8)),
            Text(
              title,
              style: GoogleFonts.vt323(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
            Text(
              description,
              style: GoogleFonts.vt323(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
