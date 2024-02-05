import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermissionType {
  notification,
  location,
  locationBackground,
  camera,
  gallery,
  bluetoothScan,
  bluetoothConnect,
  microphone,
}

enum PlatformType {
  // default value
  undefined,

  /// iOS Platform.
  iosApp,

  /// Android Platform.
  androidApp,

  /// Web Platform.
  webApp,
}

final _permissionService = PermissionService();

class AppWebView extends StatelessWidget {
  const AppWebView({
    Key? key,
    required this.url,
  }) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppWebViewPage(
        initialUrl: url,
      ),
    );
  }
}

class AppWebViewPage extends StatelessWidget {
  const AppWebViewPage({
    Key? key,
    this.initialUrl,
    this.openHttpLinkOnBrowser = false,
  }) : super(key: key);

  final String? initialUrl;
  final bool openHttpLinkOnBrowser;

  @override
  Widget build(BuildContext context) {
    final safeInitialUrl = initialUrl;

    return InAppWebView(
      initialUrlRequest: safeInitialUrl != null
          ? URLRequest(
              url: WebUri(
                safeInitialUrl,
                forceToStringRawValue: true,
              ),
            )
          : null,
      initialSettings: InAppWebViewSettings(
        useShouldOverrideUrlLoading: true,
      ),
      onPermissionRequest: (controller, PermissionRequest request) async {
        final permissionStatuses = <PermissionStatus>[];

        for (final permission in request.resources) {
          if (permission == PermissionResourceType.MICROPHONE) {
            await _permissionService.checkAndRequestPermissions(
              permissionTypes: [PermissionType.microphone],
              onGranted: () => permissionStatuses.add(PermissionStatus.granted),
            );
          }
        }

        return PermissionResponse(
          resources: request.resources,
          action: permissionStatuses.every((status) => status.isGranted)
              ? PermissionResponseAction.GRANT
              : PermissionResponseAction.DENY,
        );
      },
    );
  }
}

class PermissionService {
  Future<bool> checkAndRequestPermissions({
    required List<PermissionType> permissionTypes,
    Function? onGranted,
    Function? onDenied,
  }) async {
    final permissionList = [Permission.microphone];

    /// Request for permission if needed
    /// Note if permission is already granted, it won't display system popup
    final permissionsResultMap = await permissionList.request();

    /// Execute scenario functions of permission status result
    return _executeOnResult(
      permissionsResultMap.values,
      onGranted: onGranted,
      onDenied: onDenied,
    );
  }

  Future<bool> _executeOnResult(
    Iterable<PermissionStatus> results, {
    Function? onGranted,
    Function? onDenied,
  }) async {
    final permissionNotGranted = results.firstWhereOrNull(
      (result) => result != PermissionStatus.granted,
    );
    final allPermissionsGranted = permissionNotGranted == null;

    if (allPermissionsGranted) {
      /// On granted we execute associated function if any
      onGranted?.call();
    } else {
      // If we specified a specific deny method, we call it
      onDenied?.call();
    }

    return allPermissionsGranted;
  }
}
