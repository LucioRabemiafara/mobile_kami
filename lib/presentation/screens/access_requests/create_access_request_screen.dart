import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/zone_model.dart';
import '../../../injection_container.dart' as di;
import '../../blocs/access_request/access_request_bloc.dart';
import '../../blocs/access_request/access_request_event.dart';
import '../../blocs/access_request/access_request_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/app_dialogs.dart';

/// Create Access Request Screen
///
/// Form-based screen (NO QR CODE) for users to request temporary access
/// to zones they don't have permission for
class CreateAccessRequestScreen extends StatelessWidget {
  final ZoneModel? preselectedZone;

  const CreateAccessRequestScreen({
    super.key,
    this.preselectedZone,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AccessRequestBloc>(),
      child: _CreateAccessRequestView(preselectedZone: preselectedZone),
    );
  }
}

class _CreateAccessRequestView extends StatefulWidget {
  final ZoneModel? preselectedZone;

  const _CreateAccessRequestView({this.preselectedZone});

  @override
  State<_CreateAccessRequestView> createState() => _CreateAccessRequestViewState();
}

class _CreateAccessRequestViewState extends State<_CreateAccessRequestView> {
  final _formKey = GlobalKey<FormState>();
  final _justificationController = TextEditingController();

  // Will be populated from API
  List<ZoneModel> _availableZones = [];
  ZoneModel? _selectedZone;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Fetch all zones from API
    context.read<AccessRequestBloc>().add(const ZonesRequested());

    // Set preselected zone if provided
    if (widget.preselectedZone != null) {
      _selectedZone = widget.preselectedZone;
    }
  }

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime now = DateTime.now();
    // Backend requires dates in the future, so start from tomorrow
    final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? tomorrow,
      firstDate: tomorrow, // Start from tomorrow (future dates only)
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Also select time
      if (mounted) {
        final TimeOfDay? timePicked = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 9, minute: 0),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (timePicked != null && mounted) {
          setState(() {
            _startDate = DateTime(
              picked.year,
              picked.month,
              picked.day,
              timePicked.hour,
              timePicked.minute,
            );
            // Reset end date if it's before start date
            if (_endDate != null && _endDate!.isBefore(_startDate!)) {
              _endDate = null;
            }
          });
        }
      }
    }
  }

  Future<void> _selectEndDate() async {
    // End date must be at least the start date, or tomorrow if no start date
    final DateTime now = DateTime.now();
    final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    final DateTime minDate = _startDate ?? tomorrow;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? minDate,
      firstDate: minDate, // Must be at least start date or tomorrow
      lastDate: DateTime(minDate.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Also select time
      if (mounted) {
        final TimeOfDay? timePicked = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 17, minute: 0),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (timePicked != null && mounted) {
          setState(() {
            _endDate = DateTime(
              picked.year,
              picked.month,
              picked.day,
              timePicked.hour,
              timePicked.minute,
            );
          });
        }
      }
    }
  }

  void _submitRequest() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une zone'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date de début'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date de fin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate that dates are in the future (backend requirement)
    final DateTime now = DateTime.now();
    if (_startDate!.isBefore(now) || _startDate!.isAtSameMomentAs(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de début doit être dans le futur'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(now) || _endDate!.isAtSameMomentAs(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de fin doit être dans le futur'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate that end date is after start date
    if (_endDate!.isBefore(_startDate!) || _endDate!.isAtSameMomentAs(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de fin doit être après la date de début'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Get current user
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur non authentifié'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Submit request
    int zoneId;
    try {
      zoneId = int.parse(_selectedZone!.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ID de zone invalide (${_selectedZone!.id})'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<AccessRequestBloc>().add(CreateRequestSubmitted(
          userId: authState.user.id,
          zoneId: zoneId,
          startDate: _startDate!,
          endDate: _endDate!,
          justification: _justificationController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demander un Accès Temporaire'),
      ),
      body: BlocConsumer<AccessRequestBloc, AccessRequestState>(
        listener: (context, state) {
          if (state is ZonesLoaded) {
            // Update available zones when loaded
            print('📱 CreateAccessRequestScreen: ZonesLoaded listener - ${state.zones.length} zones');
            setState(() {
              _availableZones = List.from(state.zones);
              print('📱 Local _availableZones updated: ${_availableZones.length} zones');
              // If preselected zone is set and not in the list, add it
              if (widget.preselectedZone != null &&
                  !_availableZones.any((z) => z.id == widget.preselectedZone!.id)) {
                _availableZones.insert(0, widget.preselectedZone!);
              }
            });
          } else if (state is ZonesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors du chargement des zones: ${state.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is CreatingAccessRequest) {
            AppDialogs.showLoading(
              context: context,
              message: 'Envoi de la demande...',
            );
          } else if (state is AccessRequestCreated) {
            AppDialogs.hide(context);
            AppDialogs.showSuccess(
              context: context,
              title: 'Demande Envoyée',
              message: 'Votre demande d\'accès a été envoyée avec succès.\n\nVous recevrez une notification une fois qu\'elle sera traitée.',
              buttonText: 'OK',
              onConfirm: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close screen
              },
            );
          } else if (state is AccessRequestError) {
            AppDialogs.hide(context);
            AppDialogs.showError(
              context: context,
              title: 'Erreur',
              message: state.message,
              buttonText: 'OK',
            );
          }
        },
        builder: (context, state) {
          print('📱 Builder called - State: ${state.runtimeType}');
          final isLoading = state is CreatingAccessRequest;
          final isLoadingZones = state is ZonesLoading;

          // Get zones to display - use from state if available, otherwise use local cache
          List<ZoneModel> zonesToDisplay = _availableZones;
          if (state is ZonesLoaded) {
            zonesToDisplay = state.zones;
            print('📱 Using zones from ZonesLoaded state: ${zonesToDisplay.length}');
          } else {
            print('📱 Using local _availableZones: ${zonesToDisplay.length}');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cette demande sera examinée par un administrateur',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Zone selector
                  const Text(
                    'Zone',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isLoadingZones)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Chargement des zones...',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (zonesToDisplay.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        'Aucune zone disponible.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    )
                  else
                    DropdownButtonFormField<ZoneModel>(
                      value: _selectedZone,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Sélectionner une zone',
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      items: zonesToDisplay.map((zone) {
                        return DropdownMenuItem(
                          value: zone,
                          child: Text(
                            '${zone.name} - ${zone.building}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _selectedZone = value;
                              });
                            },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner une zone';
                        }
                        return null;
                      },
                    ),

                  const SizedBox(height: 24),

                  // Start date
                  const Text(
                    'Date et heure de début',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: isLoading ? null : _selectStartDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: _startDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _startDate = null;
                                          _endDate = null;
                                        });
                                      },
                              )
                            : null,
                      ),
                      child: Text(
                        _startDate != null
                            ? DateFormat('EEE d MMM yyyy HH:mm', 'fr_FR')
                                .format(_startDate!)
                            : 'Sélectionner la date de début',
                        style: TextStyle(
                          color: _startDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // End date
                  const Text(
                    'Date et heure de fin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: isLoading || _startDate == null ? null : _selectEndDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.event),
                        suffixIcon: _endDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _endDate = null;
                                        });
                                      },
                              )
                            : null,
                      ),
                      child: Text(
                        _endDate != null
                            ? DateFormat('EEE d MMM yyyy HH:mm', 'fr_FR')
                                .format(_endDate!)
                            : _startDate == null
                                ? 'Sélectionnez d\'abord la date de début'
                                : 'Sélectionner la date de fin',
                        style: TextStyle(
                          color: _endDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Justification
                  const Text(
                    'Justification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _justificationController,
                    enabled: !isLoading,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Expliquez pourquoi vous avez besoin d\'accéder à cette zone...',
                      helperText: 'Minimum 20 caractères',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La justification est obligatoire';
                      }
                      if (value.trim().length < 20) {
                        return 'La justification doit contenir au moins 20 caractères';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Annuler',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitRequest,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Envoyer la Demande',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
