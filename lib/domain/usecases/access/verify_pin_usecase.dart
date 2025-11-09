import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/access_verify_response_model.dart';
import '../../../data/repositories/access_repository.dart';

/// Verify PIN UseCase
///
/// Verifies the PIN code for high-security zones.
/// Used after verifyAccess returns PENDING_PIN status.
@injectable
class VerifyPinUseCase {
  final AccessRepository _accessRepository;

  VerifyPinUseCase(this._accessRepository);

  /// Execute PIN verification
  ///
  /// [userId] User ID (int)
  /// [pinCode] 4-digit PIN code entered by user
  /// [eventId] Event ID received from verifyAccess response
  ///
  /// Returns Either<Failure, AccessVerifyResponseModel>
  /// Response status will be: GRANTED or DENIED
  Future<Either<Failure, AccessVerifyResponseModel>> call({
    required int userId,
    required String pinCode,
    required int eventId,
  }) async {
    return await _accessRepository.verifyPin(
      userId: userId,
      pinCode: pinCode,
      eventId: eventId,
    );
  }
}
