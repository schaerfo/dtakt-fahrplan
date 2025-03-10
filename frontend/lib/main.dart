import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';

import 'models/search_parameters.dart';
import 'models/types.dart';
import 'widgets/info_buttons.dart';
import 'widgets/result_display.dart';
import 'widgets/search_parameter_input.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        colorSchemeSeed: _seedColor,
        textTheme: TextTheme(
          titleMedium: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          displayMedium: GoogleFonts.comfortaa(
            fontWeight: FontWeight.w600,
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
      home: Scaffold(
        body: Home(),
      ),
    );
  }
}

class Home extends StatelessWidget {
  final _parameterInputKey = GlobalKey();

  Home({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final endpoints = Provider.of<EndpointNotifier>(context);
    if (endpoints.bothEndpointsSet) {
      return Column(
        children: [
          Container(
            alignment: Alignment.center,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: InfoButtons(),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    SearchParameterInput(key: _parameterInputKey),
                    ResultDisplay(),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.title,
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          InfoButtons(),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: SearchParameterInput(key: _parameterInputKey),
          ),
        ],
      ),
    );
  }
}
