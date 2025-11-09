import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/zone_model.dart';
import '../../../data/repositories/zone_repository.dart';

/// Get All Zones UseCase
///
/// Retrieves all zones from the system
@injectable
class GetAllZonesUseCase {
  final ZoneRepository _zoneRepository;

  GetAllZonesUseCase(this._zoneRepository);

  /// Execute get all zones
  ///
  /// Returns Either<Failure, List<ZoneModel>>
  Future<Either<Failure, List<ZoneModel>>> call() async {
    return await _zoneRepository.getAllZones();
  }
}
