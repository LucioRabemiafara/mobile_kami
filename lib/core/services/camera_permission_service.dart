import 'package:permission_handler/permission_handler.dart';

/// Camera Permission Service
///
/// Handles camera permissions for QR scanner
class CameraPermissionService {
  /// Check if camera permission is granted
  Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission
  /// Returns true if granted, false otherwise
  Future<bool> requestCameraPermission() async {
    print('📷 Requesting camera permission...');

    final status = await Permission.camera.request();
    print('📷 Camera permission status: $status');

    if (status.isGranted) {
      print('✅ Camera permission granted');
      return true;
    } else if (status.isDenied) {
      print('❌ Camera permission denied');
      return false;
    } else if (status.isPermanentlyDenied) {
      print('⚠️ Camera permission permanently denied - opening settings');
      // Open app settings so user can grant permission
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// Check and request permission if needed
  Future<bool> ensureCameraPermission() async {
    // Check if already granted
    if (await isCameraPermissionGranted()) {
      print('✅ Camera permission already granted');
      return true;
    }

    // Request permission
    return await requestCameraPermission();
  }
}
