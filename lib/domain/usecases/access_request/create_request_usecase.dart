import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/access_request_model.dart';
import '../../../data/repositories/access_request_repository.dart';

/// Create Request UseCase
///
/// Creates a new access request for a zone.
/// Used when a user needs temporary access to a zone they don't normally have access to.
@injectable
class CreateRequestUseCase {
  final AccessRequestRepository _accessRequestRepository;

  CreateRequestUseCase(this._accessRequestRepository);

  /// Execute create request
  ///
  /// [userId] User ID (int)
  /// [zoneId] Zone ID to request access for (int)
  /// [startDate] Start date of requested access period
  /// [endDate] End date of requested access period
  /// [justification] Reason for requesting access
  ///
  /// Returns Either<Failure, AccessRequestModel>
  Future<Either<Failure, AccessRequestModel>> call({
    required int userId,
    required int zoneId,
    required DateTime startDate,
    required DateTime endDate,
    required String justification,
  }) async {
    return await _accessRequestRepository.createRequest(
      userId: userId,
      zoneId: zoneId,
      startDate: startDate,
      endDate: endDate,
      justification: justification,
    );
  }
}
