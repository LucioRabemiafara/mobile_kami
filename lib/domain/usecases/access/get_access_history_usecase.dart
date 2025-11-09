import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/access_event_model.dart';
import '../../../data/repositories/access_repository.dart';

/// Get Access History UseCase
///
/// Retrieves the access history for a user.
/// Can be filtered by date range.
@injectable
class GetAccessHistoryUseCase {
  final AccessRepository _accessRepository;

  GetAccessHistoryUseCase(this._accessRepository);

  /// Execute get access history
  ///
  /// [userId] User ID (int)
  /// [startDate] Optional start date filter
  /// [endDate] Optional end date filter
  ///
  /// Returns Either<Failure, List<AccessEventModel>>
  Future<Either<Failure, List<AccessEventModel>>> call({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _accessRepository.getAccessHistory(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
