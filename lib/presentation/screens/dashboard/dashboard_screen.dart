import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/dashboard/dashboard_bloc.dart';
import '../../blocs/dashboard/dashboard_event.dart';
import '../../blocs/dashboard/dashboard_state.dart';
import '../../widgets/dashboard/kpi_card.dart';
import '../access/device_unlock_screen.dart';
import '../attendance/attendance_screen.dart';
import '../zones/my_zones_screen.dart';
import '../profile/profile_screen.dart';
import '../access_requests/my_access_requests_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Dashboard Screen
///
/// Main screen of the app showing KPIs, charts, and navigation
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
//  await initializeDateFormatting('fr_FR', null);
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<DashboardBloc>().add(const DashboardDataRequested());
    }
  }

  Future<void> _onRefresh() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<DashboardBloc>().add(const DashboardRefreshRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final authState = context.watch<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return AppBar(title: const Text('Dashboard'));
    }

    final user = authState.user;
    final now = DateTime.now();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Format de date adapté à la taille d'écran
    final dateFormatter = isSmallScreen
        ? DateFormat('EEE d MMM yyyy', 'fr_FR')
        : DateFormat('EEEE d MMMM yyyy', 'fr_FR');

    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: AppColors.secondary,
          backgroundImage:
              user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? Text(
                  '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ),
      title: Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bonjour ${user.firstName} !',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              dateFormatter.format(now),
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textOnPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      actions: [
        // MULTI-POSTES chips - Adapté selon la taille d'écran
        if (user.posts.isNotEmpty && screenWidth > 360)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: user.posts.take(screenWidth > 400 ? 2 : 1).map((post) {
                return Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Chip(
                    label: Text(
                      _formatPostName(post),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DashboardError) {
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
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadDashboardData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is DashboardLoaded) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Cards (2×2 Grid)
                  _buildKpiGrid(state.kpis),

                  const SizedBox(height: 24),

                  // Chart Section
                  _buildChartSection(state.kpis),

                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(),

                  const SizedBox(height: 24),

                  // Quick Menu
                  _buildQuickMenu(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildKpiGrid(state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcul du nombre de colonnes selon la largeur
        int crossAxisCount = 2;

        if (constraints.maxWidth > 900) {
          // Très grand écran (tablette en paysage)
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 600) {
          // Tablette en portrait ou grand téléphone en paysage
          crossAxisCount = 3;
        }

        final kpiItems = [
          KpiCard(
            icon: Icons.access_time,
            title: 'Heures ce mois',
            value: '${state.hoursThisMonth.toStringAsFixed(1)}h',
            color: AppColors.primary,
            subtitle: 'Moy. ${state.averageHoursPerDay.toStringAsFixed(1)}h/jour',
          ),
          KpiCard(
            icon: Icons.location_on,
            title: 'Zones accessibles',
            value: '${state.accessibleZones}',
            color: AppColors.secondary,
          ),
          KpiCard(
            icon: Icons.check_circle,
            title: 'Accès aujourd\'hui',
            value: '${state.accessesToday}',
            color: AppColors.success,
          ),
          KpiCard(
            icon: Icons.calendar_today,
            title: 'Jours travaillés',
            value: '${state.daysWorkedThisMonth}',
            color: AppColors.warning,
            subtitle: '${state.lateCount} retard(s)',
          ),
        ];

        // Utiliser GridView pour un meilleur contrôle des espacements
        // childAspectRatio = largeur / hauteur (plus petit = plus haut)
        final childAspectRatio = crossAxisCount == 4
            ? 0.85  // Pour 4 colonnes (très grand écran)
            : crossAxisCount == 3
                ? 0.80  // Pour 3 colonnes (tablette)
                : 0.75;  // Pour 2 colonnes (téléphone)

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: kpiItems.length,
          itemBuilder: (context, index) => kpiItems[index],
        );
      },
    );
  }

  Widget _buildChartSection(state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Hauteur adaptée à la largeur de l'écran
        final chartHeight = constraints.maxWidth < 360
            ? 180.0
            : constraints.maxWidth > 600
                ? 250.0
                : 200.0;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.show_chart,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Heures - 7 derniers jours',
                        style: TextStyle(
                          fontSize: constraints.maxWidth < 360 ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: chartHeight,
                  child: _buildLineChart(state.last7DaysHours),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLineChart(List<dynamic> data) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Aucune donnée disponible',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final spots = data
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              entry.value.hours,
            ))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.borderColor,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const Text('');
                }

                final date = DateTime.parse(data[index].date);
                final dayName = DateFormat('EEE', 'fr_FR').format(date);

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    dayName,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '${value.toInt()}h',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: 12,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: AppColors.primary,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Hauteur et tailles adaptées selon l'écran
        final buttonHeight = constraints.maxWidth < 360 ? 56.0 : 64.0;
        final iconSize = constraints.maxWidth < 360 ? 24.0 : 28.0;
        final fontSize = constraints.maxWidth < 360 ? 16.0 : 18.0;

        return Column(
          children: [
            // Accès Zone Button (avec scan QR + déverrouillage)
            SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Accès à une zone via scan QR avec déverrouillage natif (Access Requisition)
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DeviceUnlockScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.qr_code_scanner, size: iconSize),
                label: Text(
                  'Accéder à une Zone (Scan QR)',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Pointer Button - Attendance check-in/check-out
            SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to Attendance screen (handles unlock + QR scan internally)
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AttendanceScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.access_time, size: iconSize),
                label: Text(
                  'Pointage',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickMenu() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcul du nombre de colonnes selon la largeur
        int crossAxisCount = 2;
        double childAspectRatio = 1.75; // Further reduced to prevent overflow with subtitles

        if (constraints.maxWidth > 900) {
          // Très grand écran (tablette en paysage)
          crossAxisCount = 4;
          childAspectRatio = 1.95; // Further reduced
        } else if (constraints.maxWidth > 600) {
          // Tablette en portrait
          crossAxisCount = 3;
          childAspectRatio = 1.85; // Further reduced
        } else if (constraints.maxWidth < 360) {
          // Petit écran - on passe en 1 colonne pour plus de lisibilité
          crossAxisCount = 1;
          childAspectRatio = 3.0; // Further reduced to give adequate height
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accès rapide',
              style: TextStyle(
                fontSize: constraints.maxWidth < 360 ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: childAspectRatio,
              children: [
                _buildQuickMenuItem(
                  icon: Icons.location_city,
                  title: 'Mes Zones',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyZonesScreen(),
                      ),
                    );
                  },
                ),
                _buildQuickMenuItem(
                  icon: Icons.qr_code_scanner,
                  title: 'Accès Zone',
                  subtitle: 'Scan QR',
                  onTap: () {
                    // Access Requisition: QR-based zone access (for users with permission)
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DeviceUnlockScreen(),
                      ),
                    );
                  },
                ),
                _buildQuickMenuItem(
                  icon: Icons.description,
                  title: 'Mes Demandes',
                  subtitle: 'Accès temporaire',
                  onTap: () {
                    // Access Request: Form-based temporary access request
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyAccessRequestsScreen(),
                      ),
                    );
                  },
                ),
                _buildQuickMenuItem(
                  icon: Icons.person,
                  title: 'Profil',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Optimized padding
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 22, // Slightly smaller icon
              ),
              const SizedBox(width: 10), // Reduced spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13, // Slightly smaller
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10, // Slightly smaller
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });

        // Handle navigation based on index
        switch (index) {
          case 0:
            // Already on Dashboard
            break;
          case 1:
            // Demande d'accès à une zone via scan QR avec déverrouillage natif
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const DeviceUnlockScreen(),
              ),
            );
            break;
          case 2:
            // Pointer via scan QR avec déverrouillage natif
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const DeviceUnlockScreen(),
              ),
            );
            break;
          case 3:
            // Historique
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Écran Historique disponible prochainement'),
              ),
            );
            break;
          case 4:
            // Profil
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Accès Zone',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.login),
          label: 'Pointer',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Historique',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  String _formatPostName(String post) {
    // Convert POST_NAME to readable format
    switch (post.toUpperCase()) {
      case 'DEVELOPER':
        return 'DEV';
      case 'DEVOPS':
        return 'DEVOPS';
      case 'SECURITY_AGENT':
        return 'SECURITE';
      case 'MANAGER':
        return 'MANAGER';
      case 'HR':
        return 'RH';
      default:
        return post.length > 8 ? post.substring(0, 8) : post;
    }
  }
}
