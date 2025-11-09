import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/access_verify_response_model.dart';
import '../../../data/repositories/access_repository.dart';

/// Verify Access UseCase ⭐
///
/// Verifies if a user can access a zone via QR code.
/// IMPORTANT: Native device unlock must be verified BEFORE calling this UseCase
@injectable
class VerifyAccessUseCase {
  final AccessRepository _accessRepository;

  VerifyAccessUseCase(this._accessRepository);

  /// Execute access verification
  ///
  /// [userId] User ID (int)
  /// [qrCode] Scanned QR code
  /// [deviceInfo] Device information (optional)
  /// [ipAddress] IP address (optional)
  ///
  /// Returns Either<Failure, AccessVerifyResponseModel>
  /// Response status can be: GRANTED, PENDING_PIN, or DENIED
  Future<Either<Failure, AccessVerifyResponseModel>> call({
    required int userId,
    required String qrCode,
    String? deviceInfo,
    String? ipAddress,
  }) async {
    return await _accessRepository.verifyAccess(
      userId: userId,
      qrCode: qrCode,
      deviceInfo: deviceInfo,
      ipAddress: ipAddress,
    );
  }
}
