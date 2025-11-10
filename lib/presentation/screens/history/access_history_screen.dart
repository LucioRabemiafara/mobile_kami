import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/access_event_model.dart';
import '../../blocs/access/access_bloc.dart';
import '../../blocs/access/access_event.dart';
import '../../blocs/access/access_state.dart';

/// Access History Screen
///
/// Displays the user's access history with filtering options
class AccessHistoryScreen extends StatefulWidget {
  const AccessHistoryScreen({super.key});

  @override
  State<AccessHistoryScreen> createState() => _AccessHistoryScreenState();
}

class _AccessHistoryScreenState extends State<AccessHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Load history on screen open
    context.read<AccessBloc>().add(const AccessHistoryRequested());
  }

  /// Show date picker for start date
  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = DateTime(picked.year, picked.month, picked.day);
      });
      _applyFilter();
    }
  }

  /// Show date picker for end date
  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      });
      _applyFilter();
    }
  }

  /// Apply date filter
  void _applyFilter() {
    context.read<AccessBloc>().add(
          AccessHistoryRequested(
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
  }

  /// Clear all filters
  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    context.read<AccessBloc>().add(const AccessHistoryRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Historique d\'Accès'),
        elevation: 0,
        actions: [
          if (_startDate != null || _endDate != null)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearFilters,
              tooltip: 'Effacer les filtres',
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),

          // History List
          Expanded(
            child: BlocBuilder<AccessBloc, AccessState>(
              builder: (context, state) {
                if (state is AccessHistoryLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is AccessHistoryError) {
                  return _buildErrorView(state.message);
                } else if (state is AccessHistoryLoaded) {
                  return _buildHistoryList(state.events);
                }

                // Initial state or other states
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter section
  Widget _buildFilterSection() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrer par période',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Start Date
              Expanded(
                child: _buildDateFilterButton(
                  label: 'Date début',
                  date: _startDate,
                  onTap: _selectStartDate,
                ),
              ),
              const SizedBox(width: 12),
              // End Date
              Expanded(
                child: _buildDateFilterButton(
                  label: 'Date fin',
                  date: _endDate,
                  onTap: _selectEndDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build date filter button
  Widget _buildDateFilterButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: date != null ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Non définie',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: date != null ? AppColors.textPrimary : AppColors.textHint,
                      fontWeight: date != null ? FontWeight.w500 : FontWeight.normal,
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

  /// Build error view
  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AccessBloc>().add(
                      AccessHistoryRequested(
                        startDate: _startDate,
                        endDate: _endDate,
                      ),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build history list
  Widget _buildHistoryList(List<AccessEventModel> events) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun historique',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 8),
              Text(
                _startDate != null || _endDate != null
                    ? 'Aucun accès trouvé pour cette période'
                    : 'Vous n\'avez pas encore d\'historique d\'accès',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AccessBloc>().add(
              AccessHistoryRequested(
                startDate: _startDate,
                endDate: _endDate,
              ),
            );
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: events.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final event = events[index];
          return _buildHistoryCard(event);
        },
      ),
    );
  }

  /// Build history card
  Widget _buildHistoryCard(AccessEventModel event) {
    final isGranted = event.status == 'GRANTED';
    final isPendingPin = event.status == 'PENDING_PIN';
    final isDenied = event.status == 'DENIED';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isGranted) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle;
      statusText = 'Accordé';
    } else if (isPendingPin) {
      statusColor = AppColors.warning;
      statusIcon = Icons.lock;
      statusText = 'PIN requis';
    } else {
      statusColor = AppColors.error;
      statusIcon = Icons.cancel;
      statusText = 'Refusé';
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Status and Time
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('HH:mm').format(event.timestamp),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Zone Name
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.zoneName ?? 'Zone inconnue',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMMM yyyy', 'fr_FR').format(event.timestamp),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            // Method
            if (event.method.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.qr_code,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    event.method == 'QR' ? 'Scan QR' : 'QR + PIN',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],

            // Device Unlocked Badge
            if (event.deviceUnlocked) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.security,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Appareil déverrouillé',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Reason (if denied)
            if (isDenied && event.reason != null && event.reason!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.reason!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
