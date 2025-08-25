// lib/screens/coordinator_list_screen.dart
import 'package:flutter/material.dart';
import '../widgets/leopard_app_bar.dart';
import '../widgets/retro_panel.dart';
import '../utils/responsive_helper.dart';
import '../backend/coordinator_service.dart';
import '../models/coordinator_application.dart';

class CoordinatorListScreen extends StatefulWidget {
  const CoordinatorListScreen({super.key});

  @override
  State<CoordinatorListScreen> createState() => _CoordinatorListScreenState();
}

class _CoordinatorListScreenState extends State<CoordinatorListScreen> {
  List<CoordinatorApplication> _applications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final applications =
          await CoordinatorService.getCoordinatorApplications();

      setState(() {
        _applications = applications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(
    String applicationId,
    CoordinatorStatus newStatus,
  ) async {
    try {
      final success = await CoordinatorService.updateApplicationStatus(
        applicationId,
        newStatus,
      );

      if (success) {
        setState(() {
          final index = _applications.indexWhere(
            (app) => app.id == applicationId,
          );
          if (index != -1) {
            _applications[index] = _applications[index].copyWith(
              status: newStatus,
            );
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Application ${newStatus.name} successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update status'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const LeopardAppBar(
        title: Text('Co-ordinator Applications'),
        actions: [
          // Refresh button handled by pull-to-refresh
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadApplications,
        child: Padding(
          padding: ResponsiveHelper.getResponsivePadding(context, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              RetroPanel(
                child: Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Co-ordinator Applications',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _isLoading
                                ? 'Loading applications...'
                                : '${_applications.length} applications submitted',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveSpacing(context, 24),
              ),

              // Content
              Expanded(child: _buildContent(theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: RetroPanel(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading applications',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadApplications,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_applications.isEmpty) {
      return Center(
        child: RetroPanel(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No coordinator applications submitted yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // *** THE FIX: Grid layout for ID card-style display ***
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isSmallScreen(context) ? 1 : 2,
        childAspectRatio: ResponsiveHelper.isSmallScreen(context) ? 2.5 : 2.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _applications.length,
      itemBuilder: (context, index) {
        final application = _applications[index];
        return _IDCard(
          application: application,
          onStatusChanged: (newStatus) =>
              _updateStatus(application.id, newStatus),
        );
      },
    );
  }
}

// *** THE FIX: New ID Card-style widget ***
class _IDCard extends StatelessWidget {
  final CoordinatorApplication application;
  final Function(CoordinatorStatus) onStatusChanged;

  const _IDCard({required this.application, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 8,
      shadowColor: theme.shadowColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getStatusColor(application.status).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header with status
              Row(
                children: [
                  Icon(
                    Icons.badge_outlined,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CO-ORDINATOR ID',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  _StatusChip(status: application.status),
                ],
              ),
              const SizedBox(height: 12),

              // Main content
              Expanded(
                child: Row(
                  children: [
                    // ID Photo
                    Container(
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: application.idCardUrl != null
                            ? Image.network(
                                application.idCardUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholderPhoto(theme),
                              )
                            : _buildPlaceholderPhoto(theme),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            application.name.toUpperCase(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          _DetailRow(
                            icon: Icons.numbers,
                            label: 'Enrollment',
                            value: application.enrollmentNo,
                            theme: theme,
                          ),
                          const SizedBox(height: 4),
                          _DetailRow(
                            icon: Icons.class_outlined,
                            label: 'Division',
                            value: application.division,
                            theme: theme,
                          ),
                          const SizedBox(height: 4),
                          _DetailRow(
                            icon: Icons.school_outlined,
                            label: 'Department',
                            value: application.department,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Footer with actions and timestamp
              const Divider(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Submitted ${_formatDate(application.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),
                  if (application.status == CoordinatorStatus.pending) ...[
                    IconButton(
                      onPressed: () =>
                          onStatusChanged(CoordinatorStatus.rejected),
                      icon: const Icon(Icons.close, size: 18),
                      color: Colors.red,
                      tooltip: 'Reject',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () =>
                          onStatusChanged(CoordinatorStatus.approved),
                      icon: const Icon(Icons.check, size: 18),
                      color: Colors.green,
                      tooltip: 'Approve',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderPhoto(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 4),
          Text(
            'ID PHOTO',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(CoordinatorStatus status) {
    switch (status) {
      case CoordinatorStatus.pending:
        return Colors.orange;
      case CoordinatorStatus.approved:
        return Colors.green;
      case CoordinatorStatus.rejected:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final CoordinatorStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case CoordinatorStatus.pending:
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange.shade700;
        text = 'PENDING';
        icon = Icons.hourglass_empty;
        break;
      case CoordinatorStatus.approved:
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green.shade700;
        text = 'APPROVED';
        icon = Icons.check_circle;
        break;
      case CoordinatorStatus.rejected:
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red.shade700;
        text = 'REJECTED';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
