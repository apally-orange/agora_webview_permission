import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.open_in_browser),
        onPressed: () => launchUrlString(url),
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
        isInspectable: kDebugMode,
        mediaPlaybackRequiresUserGesture: false,
        javaScriptEnabled: true,
        iframeAllow: "camera; microphone",
      ),
      onPermissionRequest: (controller, PermissionRequest request) async {
        await Permission.microphone.request();

        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
    );
  }
}
