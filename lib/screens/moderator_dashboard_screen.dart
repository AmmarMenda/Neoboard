// lib/screens/moderator_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../widgets/retro_button.dart' as retro;
import '../utils/responsive_helper.dart';
import 'board_list_screen.dart';
import 'moderator_thread_management_screen.dart';
import 'moderator_report_screen.dart';
import '../widgets/leopard_app_bar.dart'; // Use the themed AppBar
import '../widgets/retro_panel.dart'; // Use the themed Panel

class ModeratorDashboardScreen extends StatelessWidget {
  const ModeratorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme for styling

    return Scaffold(
      // *** THE FIX: Use the themed LeopardAppBar and Scaffold background ***
      appBar: LeopardAppBar(
        title: const Text('Moderator Dashboard'),

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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: ResponsiveHelper.getResponsivePadding(context, 16, 24),
        child: Column(
          children: [
            // *** THE FIX: Welcome Header is now a themed RetroPanel ***
            RetroPanel(
              child: Column(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: ResponsiveHelper.isSmallScreen(context) ? 40 : 52,
                    color:
                        theme.colorScheme.primary, // Use theme's primary color
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveSpacing(context, 8),
                  ),
                  Text(
                    'MODERATOR PANEL',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveSpacing(context, 4),
                  ),
                  Text(
                    'Manage threads, posts, and user reports',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(context, 24),
            ),

            // Action Buttons Grid - Responsive layout is preserved
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;
                  double childAspectRatio;

                  if (constraints.maxWidth < 600) {
                    crossAxisCount = 1;
                    childAspectRatio = 4.0;
                  } else {
                    crossAxisCount = 2;
                    childAspectRatio = 2.0;
                  }
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      16,
                    ),
                    mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                      context,
                      16,
                    ),
                    childAspectRatio: childAspectRatio,
                    children: [
                      _ModeratorActionCard(
                        icon: Icons.forum_outlined,
                        title: 'Manage Threads',
                        description: 'View and delete threads',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ModeratorThreadManagementScreen(),
                          ),
                        ),
                      ),
                      _ModeratorActionCard(
                        icon: Icons.flag_outlined,
                        title: 'Reports',
                        description: 'Handle user reports',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ModeratorReportsScreen(),
                          ),
                        ),
                      ),
                      _ModeratorActionCard(
                        icon: Icons.people_outline,
                        title: 'User Management',
                        description: 'Manage user accounts',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User management coming soon!'),
                          ),
                        ),
                      ),
                      _ModeratorActionCard(
                        icon: Icons.settings_outlined,
                        title: 'Board Settings',
                        description: 'Configure board settings',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Settings coming soon!'),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Back to Home Button
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(context, 16),
            ),
            retro.RetroButton(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const BoardListScreen()),
                  (route) => false,
                );
              },
              // *** THE FIX: Text inherits its style from the button ***
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Back to Home'),
                ],
              ),
            ),
          ],
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
    final theme = Theme.of(context);

    // *** THE FIX: The card is now a themed RetroPanel ***
    return GestureDetector(
      onTap: onTap,
      child: RetroPanel(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: ResponsiveHelper.isSmallScreen(context) ? 32 : 40,
              color: theme.colorScheme.primary,
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(context, 12),
            ),
            // *** THE FIX: Text now uses themed styles ***
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
            Text(
              description,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
