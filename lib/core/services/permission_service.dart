import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Requests camera permission and returns true if granted.
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;

    final result = await Permission.camera.request();
    return result.isGranted;
  }

  /// Requests photo/gallery related permissions.
  /// On Android this will try storage permissions as a fallback.
  static Future<bool> requestGalleryPermission() async {
    // Try a few relevant permissions. The permission_handler package
    // exposes different permissions across platforms and Android API versions.
    // We'll attempt them in order and consider the permission granted if any succeeds.

    // Try photos permission first (works for iOS and maps to READ_MEDIA_* on newer Android)
    final photosStatus = await Permission.photos.status;
    if (photosStatus.isGranted) return true;
    final photosResult = await Permission.photos.request();
    if (photosResult.isGranted) return true;

    // On Android try storage fallback for older devices
    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) return true;
      final storageResult = await Permission.storage.request();
      if (storageResult.isGranted) return true;
    }

    // Try mediaLibrary as another fallback (some platforms expose this)
    final mediaStatus = await Permission.mediaLibrary.status;
    if (mediaStatus.isGranted) return true;
    final mediaResult = await Permission.mediaLibrary.request();
    if (mediaResult.isGranted) return true;

    return false;
  }

  /// If the permission is permanently denied, open app settings.
  static Future<void> openSettingsIfNeeded(PermissionStatus status) async {
    if (status.isPermanentlyDenied || status.isRestricted) {
      await openAppSettings();
    }
  }
}
