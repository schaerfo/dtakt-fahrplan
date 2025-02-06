import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'models/search_parameters.dart';
import 'widgets/search_parameter_input.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SearchParameters(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  static const _seedColor = Colors.indigo;

  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(colorSchemeSeed: _seedColor),
      darkTheme: ThemeData(
        colorSchemeSeed: _seedColor,
        brightness: Brightness.dark,
      ),
      home: const Scaffold(
        body: Center(
          child: SearchParameterInput(),
        ),
      ),
    );
  }
}
