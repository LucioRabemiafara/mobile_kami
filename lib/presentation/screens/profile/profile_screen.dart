import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../auth/login_screen.dart';

/// Profile Screen
///
/// Displays user profile information and logout option
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(
              child: Text('Utilisateur non authentifié'),
            );
          }

          final user = state.user;
          final dateFormatter = DateFormat('d MMMM yyyy', 'fr_FR');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile header
                Center(
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: user.photoUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  user.photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildInitials(user);
                                  },
                                ),
                              )
                            : _buildInitials(user),
                      ),

                      const SizedBox(height: 16),

                      // Name
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      // Email
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Posts chips (MULTI-POSTES)
                      if (user.posts.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: user.posts.map((post) {
                            return Chip(
                              label: Text(
                                _formatPostName(post),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: AppColors.secondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Information cards
                _buildInfoCard(
                  icon: Icons.badge,
                  title: 'Rôle',
                  value: _formatRole(user.role),
                ),
                _buildInfoCard(
                  icon: Icons.business,
                  title: 'Département',
                  value: user.department,
                ),
                if (user.hireDate != null)
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Date d\'embauche',
                    value: dateFormatter.format(user.hireDate!),
                  ),
                _buildInfoCard(
                  icon: Icons.verified_user,
                  title: 'Statut',
                  value: user.isActive ? 'Actif' : 'Inactif',
                  valueColor:
                      user.isActive ? AppColors.success : AppColors.error,
                ),
                if (user.isAdmin)
                  _buildInfoCard(
                    icon: Icons.admin_panel_settings,
                    title: 'Privilèges',
                    value: 'Administrateur',
                    valueColor: AppColors.warning,
                  ),

                const SizedBox(height: 32),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutConfirmation(context),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Se déconnecter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // App version
                Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitials(user) {
    return Center(
      child: Text(
        '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const LogoutRequested());

              // Navigate to login screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  String _formatPostName(String post) {
    switch (post.toUpperCase()) {
      case 'DEVELOPER':
        return 'Développeur';
      case 'DEVOPS':
        return 'DevOps';
      case 'SECURITY_AGENT':
        return 'Agent de Sécurité';
      case 'MANAGER':
        return 'Manager';
      case 'HR':
        return 'Ressources Humaines';
      default:
        return post;
    }
  }

  String _formatRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'Administrateur';
      case 'USER':
        return 'Utilisateur';
      case 'MANAGER':
        return 'Manager';
      default:
        return role;
    }
  }
}
