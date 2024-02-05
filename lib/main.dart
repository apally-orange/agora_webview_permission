import 'package:flutter/material.dart';
import 'package:webview_permission/app_web_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AppWebView(
        url: 'https://agora.agora.tools/#/chat/bot?ws=orange_default',
      ),
    );
  }
}
