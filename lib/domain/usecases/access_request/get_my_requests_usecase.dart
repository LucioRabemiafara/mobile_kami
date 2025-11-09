import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/access_request_model.dart';
import '../../../data/repositories/access_request_repository.dart';

/// Get My Requests UseCase
///
/// Retrieves all access requests made by a user.
/// Can be filtered by status (pending, approved, rejected).
@injectable
class GetMyRequestsUseCase {
  final AccessRequestRepository _accessRequestRepository;

  GetMyRequestsUseCase(this._accessRequestRepository);

  /// Execute get my requests
  ///
  /// [userId] User ID (int)
  ///
  /// Returns Either<Failure, List<AccessRequestModel>>
  Future<Either<Failure, List<AccessRequestModel>>> call({
    required int userId,
  }) async {
    return await _accessRequestRepository.getMyRequests(userId);
  }
}
