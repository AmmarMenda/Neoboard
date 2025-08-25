// lib/screens/moderator_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../widgets/retro_button.dart' as retro;
import '../utils/responsive_helper.dart';
import 'board_list_screen.dart';
import 'moderator_thread_management_screen.dart';
import 'moderator_report_screen.dart';
import 'coordinator_list_screen.dart'; // Add this import
import '../widgets/leopard_app_bar.dart';
import '../widgets/retro_panel.dart';

class ModeratorDashboardScreen extends StatelessWidget {
  const ModeratorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
            RetroPanel(
              child: Column(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: ResponsiveHelper.isSmallScreen(context) ? 40 : 52,
                    color: theme.colorScheme.primary,
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
                      // Updated card for Coordinator List
                      _ModeratorActionCard(
                        icon: Icons.badge_outlined, // Changed icon
                        title: 'Co-ordinator List', // Changed title
                        description:
                            'View submitted coordinator forms', // Changed description
                        onTap: () => Navigator.push(
                          // Changed navigation
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CoordinatorListScreen(),
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
