// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

import 'package:dtakt_fahrplan_frontend/util/responsive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'generated/l10n/app_localizations.dart';
import 'models/search_parameters.dart';
import 'models/types.dart';
import 'widgets/info_buttons.dart';
import 'widgets/result_display.dart';
import 'widgets/search_parameter_input.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final licenses = {
      'Comfortaa': 'assets/google_fonts/comfortaa/OFL.txt',
      'Noto Sans': 'assets/google_fonts/notosans/OFL.txt',
      'Roboto': 'assets/google_fonts/roboto/OFL.txt',
    };
    for (final item in licenses.entries) {
      final license = await rootBundle.loadString(item.value);
      yield LicenseEntryWithLineBreaks([item.key], license);
    }
  });
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EndpointNotifier()),
        ChangeNotifierProvider(
            create: (_) => TimeAnchorNotifier(TimeAnchor.depart)),
        ChangeNotifierProvider(
            create: (_) => ProductNotifier({...Product.values})),
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
        fontFamily: "Roboto",
        colorSchemeSeed: _seedColor,
        textTheme: TextTheme(
          titleMedium: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            fontFamily: "Comfortaa",
            fontWeight: FontWeight.w600,
          ),
        ),
        dividerTheme: DividerThemeData(
          space: 0,
        ),
        fontFamilyFallback: const [
          'Noto Sans',
        ],
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: _seedColor,
        brightness: Brightness.dark,
      ),
      onGenerateTitle: (context) => AppLocalizations.of(context)!.title,
      home: Scaffold(
        body: _Home(),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  final _parameterInputKey = GlobalKey();

  _Home({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final endpoints = Provider.of<EndpointNotifier>(context);
    if (endpoints.bothEndpointsSet) {
      return Column(
        children: [
          if (!useNarrowLayout(context))
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Measure the width of the unwrapped text
                final unwrappedText = AppLocalizations.of(context)!.title;
                final style = Theme.of(context).textTheme.displayMedium;
                final ts = TextSpan(
                  text: unwrappedText,
                  style: style,
                );
                final tp = TextPainter(
                  text: ts,
                  maxLines: 1,
                  textDirection: TextDirection.ltr,
                );
                tp.layout(maxWidth: constraints.maxWidth);
                final useWrappedText = tp.didExceedMaxLines;
                tp.dispose();
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    useWrappedText
                        ? AppLocalizations.of(context)!.titleWrapped
                        : unwrappedText,
                    style: style,
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
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
