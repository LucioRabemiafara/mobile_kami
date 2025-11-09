import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/access_request_model.dart';
import '../../../injection_container.dart' as di;
import '../../blocs/access_request/access_request_bloc.dart';
import '../../blocs/access_request/access_request_event.dart';
import '../../blocs/access_request/access_request_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import 'create_access_request_screen.dart';

/// My Access Requests Screen
///
/// Displays user's access requests in 3 tabs: Pending, Approved, Rejected
class MyAccessRequestsScreen extends StatelessWidget {
  const MyAccessRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = di.sl<AccessRequestBloc>();
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          bloc.add(MyRequestsRequested(authState.user.id));
        }
        return bloc;
      },
      child: const _MyAccessRequestsView(),
    );
  }
}

class _MyAccessRequestsView extends StatelessWidget {
  const _MyAccessRequestsView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Demandes d\'Accès'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.pending),
                text: 'En attente',
              ),
              Tab(
                icon: Icon(Icons.check_circle),
                text: 'Approuvées',
              ),
              Tab(
                icon: Icon(Icons.cancel),
                text: 'Rejetées',
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CreateAccessRequestScreen(),
              ),
            ).then((value) {
              // Reload requests after creating a new one
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                context
                    .read<AccessRequestBloc>()
                    .add(MyRequestsRequested(authState.user.id));
              }
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Nouvelle Demande'),
        ),
        body: BlocBuilder<AccessRequestBloc, AccessRequestState>(
          builder: (context, state) {
            if (state is AccessRequestsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AccessRequestError) {
              return _buildErrorView(context, state.message);
            }

            if (state is AccessRequestsLoaded) {
              return TabBarView(
                children: [
                  _buildRequestsList(context, state.pendingRequests, 'PENDING'),
                  _buildRequestsList(context, state.approvedRequests, 'APPROVED'),
                  _buildRequestsList(context, state.rejectedRequests, 'REJECTED'),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context
                      .read<AccessRequestBloc>()
                      .add(MyRequestsRequested(authState.user.id));
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(
    BuildContext context,
    List<AccessRequestModel> requests,
    String status,
  ) {
    if (requests.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () async {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          context
              .read<AccessRequestBloc>()
              .add(MyRequestsRequested(authState.user.id));
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestCard(context, request);
        },
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    String message;
    IconData icon;
    Color color;

    switch (status) {
      case 'PENDING':
        message = 'Aucune demande en attente';
        icon = Icons.pending_actions;
        color = AppColors.warning;
        break;
      case 'APPROVED':
        message = 'Aucune demande approuvée';
        icon = Icons.check_circle_outline;
        color = AppColors.success;
        break;
      case 'REJECTED':
        message = 'Aucune demande rejetée';
        icon = Icons.cancel_outlined;
        color = AppColors.error;
        break;
      default:
        message = 'Aucune demande';
        icon = Icons.inbox;
        color = AppColors.textSecondary;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: color.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, AccessRequestModel request) {
    final dateFormatter = DateFormat('d MMM yyyy HH:mm', 'fr_FR');
    final statusColor = _getStatusColor(request.status);
    final statusIcon = _getStatusIcon(request.status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          request.zoneName ?? request.zone?.name ?? 'Zone inconnue',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Du ${dateFormatter.format(request.startDate)} au ${dateFormatter.format(request.endDate)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            _buildStatusChip(request.status),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 12),

                // Justification
                const Text(
                  'Justification',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.justification,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),

                // Admin note (if exists)
                if (request.adminNote != null && request.adminNote!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Note de l\'administrateur',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      request.adminNote!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Metadata
                if (request.createdAt != null)
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetadataItem(
                          Icons.calendar_today,
                          'Demandé le',
                          dateFormatter.format(request.createdAt!),
                        ),
                      ),
                    ],
                  ),

                if (request.reviewedAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetadataItem(
                          Icons.person,
                          'Traité par',
                          request.reviewedBy ?? 'Administrateur',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetadataItem(
                          Icons.event_available,
                          'Traité le',
                          dateFormatter.format(request.reviewedAt!),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    final label = _getStatusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMetadataItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.warning;
      case 'APPROVED':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.pending;
      case 'APPROVED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'En attente';
      case 'APPROVED':
        return 'Approuvée';
      case 'REJECTED':
        return 'Rejetée';
      default:
        return status;
    }
  }
}
