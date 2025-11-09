import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/zone_model.dart';
import '../../../domain/usecases/user/get_access_zones_usecase.dart';
import '../../../injection_container.dart' as di;
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// My Zones Screen
///
/// Displays all zones accessible by the user with filters
class MyZonesScreen extends StatefulWidget {
  const MyZonesScreen({super.key});

  @override
  State<MyZonesScreen> createState() => _MyZonesScreenState();
}

class _MyZonesScreenState extends State<MyZonesScreen> {
  final GetAccessZonesUseCase _getAccessZonesUseCase =
      di.sl<GetAccessZonesUseCase>();

  List<ZoneModel> _zones = [];
  List<ZoneModel> _filteredZones = [];
  bool _isLoading = true;
  String? _errorMessage;

  String? _selectedSecurityLevel;
  String? _selectedBuilding;

  final List<String> _securityLevels = ['LOW', 'MEDIUM', 'HIGH'];
  List<String> _buildings = [];

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Utilisateur non authentifié';
      });
      return;
    }

    final userId = authState.user.id;
    final result = await _getAccessZonesUseCase(userId: userId);

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message ?? 'Erreur lors du chargement des zones';
        });
      },
      (zones) {
        // Zones are already ZoneModel objects from the repository
        // Extract unique buildings
        final buildingsSet = zones
            .map((z) => z.building)
            .where((b) => b.isNotEmpty)
            .toSet();

        setState(() {
          _zones = zones;
          _filteredZones = zones;
          _buildings = buildingsSet.toList()..sort();
          _isLoading = false;
        });
      },
    );
  }

  void _applyFilters() {
    setState(() {
      _filteredZones = _zones.where((zone) {
        bool matchesSecurityLevel = _selectedSecurityLevel == null ||
            zone.securityLevel.toUpperCase() ==
                _selectedSecurityLevel!.toUpperCase();
        bool matchesBuilding =
            _selectedBuilding == null || zone.building == _selectedBuilding;
        return matchesSecurityLevel && matchesBuilding;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedSecurityLevel = null;
      _selectedBuilding = null;
      _filteredZones = _zones;
    });
  }

  Color _getSecurityLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'LOW':
        return AppColors.success;
      case 'MEDIUM':
        return AppColors.warning;
      case 'HIGH':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getSecurityLevelLabel(String level) {
    switch (level.toUpperCase()) {
      case 'LOW':
        return 'Sécurité Normale';
      case 'MEDIUM':
        return 'Sécurité Renforcée';
      case 'HIGH':
        return 'Sécurité Maximale';
      default:
        return level;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Zones'),
        actions: [
          if (_selectedSecurityLevel != null || _selectedBuilding != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilters,
              tooltip: 'Effacer les filtres',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    return Column(
      children: [
        _buildFilters(),
        Expanded(child: _buildZonesList()),
      ],
    );
  }

  Widget _buildErrorView() {
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
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadZones,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.filter_list, size: 20, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Filtres',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSecurityLevel,
                    decoration: const InputDecoration(
                      labelText: 'Niveau de sécurité',
                      prefixIcon: Icon(Icons.security),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Tous'),
                      ),
                      ..._securityLevels.map((level) {
                        return DropdownMenuItem<String>(
                          value: level,
                          child: Text(_getSecurityLevelLabel(level)),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSecurityLevel = value;
                      });
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedBuilding,
                    decoration: const InputDecoration(
                      labelText: 'Bâtiment',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Tous'),
                      ),
                      ..._buildings.map((building) {
                        return DropdownMenuItem<String>(
                          value: building,
                          child: Text(building),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedBuilding = value;
                      });
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZonesList() {
    if (_filteredZones.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune zone trouvée',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Essayez de modifier les filtres',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadZones,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        itemCount: _filteredZones.length,
        itemBuilder: (context, index) {
          final zone = _filteredZones[index];
          return _buildZoneCard(zone);
        },
      ),
    );
  }

  Widget _buildZoneCard(ZoneModel zone) {
    final securityColor = _getSecurityLevelColor(zone.securityLevel);
    final securityLabel = _getSecurityLevelLabel(zone.securityLevel);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showZoneDetails(zone);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      zone.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: securityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: securityColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      securityLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: securityColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (zone.building.isNotEmpty || zone.floor > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      [
                        if (zone.building.isNotEmpty) zone.building,
                        if (zone.floor > 0) 'Étage ${zone.floor}',
                      ].join(' • '),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              if (zone.description != null && zone.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  zone.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showZoneDetails(ZoneModel zone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final securityColor = _getSecurityLevelColor(zone.securityLevel);
        final securityLabel = _getSecurityLevelLabel(zone.securityLevel);

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      zone.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: securityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: securityColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.security, size: 16, color: securityColor),
                    const SizedBox(width: 6),
                    Text(
                      securityLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: securityColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (zone.building.isNotEmpty ||
                  zone.floor > 0) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Localisation',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            [
                              if (zone.building.isNotEmpty) zone.building,
                              if (zone.floor > 0) 'Étage ${zone.floor}',
                            ].join(' • '),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (zone.description != null &&
                  zone.description!.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  zone.description!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
