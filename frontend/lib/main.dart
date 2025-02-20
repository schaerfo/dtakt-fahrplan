import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'models/search_parameters.dart';
import 'models/types.dart';
import 'widgets/result_display.dart';
import 'widgets/search_parameter_input.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EndpointNotifier()),
        ChangeNotifierProvider(
            create: (_) => TimeAnchorNotifier(TimeAnchor.depart)),
        ChangeNotifierProvider(create: (_) => ModeNotifier(Mode.all)),
        ChangeNotifierProvider(
            create: (_) => TimeNotifier(TimeOfDay(hour: 8, minute: 0))),
      ],
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
      theme: ThemeData(
        colorSchemeSeed: _seedColor,
        textTheme: TextTheme(
          titleMedium: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        dividerTheme: DividerThemeData(
          space: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: _seedColor,
        brightness: Brightness.dark,
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SearchParameterInput(),
              ResultDisplay(),
            ],
          ),
        ),
      ),
    );
  }
}
