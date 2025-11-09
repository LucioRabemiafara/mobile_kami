import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/zone_model.dart';
import '../../../data/repositories/user_repository.dart';

/// Get Access Zones UseCase
///
/// Retrieves all zones that a user can access.
/// Based on user's posts and zone's allowedPosts (MULTI-POSTES system).
@injectable
class GetAccessZonesUseCase {
  final UserRepository _userRepository;

  GetAccessZonesUseCase(this._userRepository);

  /// Execute get access zones
  ///
  /// [userId] User ID (int)
  ///
  /// Returns Either<Failure, List<ZoneModel>>
  /// Each zone contains information about access permissions
  Future<Either<Failure, List<ZoneModel>>> call({
    required int userId,
  }) async {
    return await _userRepository.getAccessZones(userId);
  }
}
