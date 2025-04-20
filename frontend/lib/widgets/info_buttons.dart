// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/journey.dart';
import '../models/types.dart';
import '../util/environment.dart';
import 'product_badge.dart';

class InfoButtons extends StatelessWidget {
  const InfoButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            _showAbout(context);
          },
          child: Text(AppLocalizations.of(context)!.about),
        ),
        Text("•"),
        TextButton(
          onPressed: () {
            _showDeutschlandtaktInformation(context);
          },
          child: Text(AppLocalizations.of(context)!.informationDeutschlandtakt),
        ),
        Text("•"),
        TextButton(
          onPressed: () {
            _showTrainCategories(context);
          },
          child: Text(AppLocalizations.of(context)!.trainCategories),
        ),
        Text("•"),
        TextButton(
          onPressed: () {
            _showDataSources(context);
          },
          child: Text(AppLocalizations.of(context)!.dataSources),
        ),
        Text("•"),
        TextButton(
          onPressed: () {
            _showLegal(context);
          },
          child: Text(AppLocalizations.of(context)!.legal),
        ),
      ],
    );
  }

  void _showAbout(BuildContext context) {
    _showDialog(
      context: context,
      titleText: AppLocalizations.of(context)!.about,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.aboutContent1,
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.aboutContent2,
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 10),
          // Left-align text by expanding horizontally
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: double.infinity),
            child: _MotisReference(),
          ),
          TextButton(
            onPressed: () {
              launchUrl(
                  Uri.parse("https://github.com/schaerfo/dtakt-fahrplan/"));
            },
            child: Text(AppLocalizations.of(context)!.sourceCode),
          ),
        ],
      ),
    );
  }

  void _showDeutschlandtaktInformation(BuildContext context) {
    _showDialog(
      context: context,
      titleText: AppLocalizations.of(context)!.informationDeutschlandtakt,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.informationDeutschlandtaktContent1,
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.informationDeutschlandtaktContent2,
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.informationDeutschlandtaktContent3,
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () {
              launchUrl(Uri.parse("https://deutschlandtakt.de"));
            },
            child: Text(AppLocalizations.of(context)!.officialWebsite),
          ),
          TextButton(
            onPressed: () {
              launchUrl(
                  Uri.parse("https://de.wikipedia.org/wiki/Deutschlandtakt"));
            },
            child:
                Text(AppLocalizations.of(context)!.informationWikipediaGerman),
          ),
        ],
      ),
    );
  }

  void _showTrainCategories(BuildContext context) {
    _showDialog(
      context: context,
      titleText: AppLocalizations.of(context)!.trainCategories,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.trainCategoriesContent1,
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.highSpeedTrains,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(width: 10),
              ProductBadge(
                Leg(
                  [],
                  id: '',
                  lineName: 'FV 1',
                  product: Product.highSpeed,
                ),
              ),
            ],
          ),
          Text(
            AppLocalizations.of(context)!.trainCategoriesContent2,
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.longDistanceTrains,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(width: 10),
              ProductBadge(
                Leg(
                  [],
                  id: '',
                  lineName: 'FR 1',
                  product: Product.longDistance,
                ),
              ),
            ],
          ),
          Text(
            AppLocalizations.of(context)!.trainCategoriesContent3,
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.regionalTrains,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(width: 10),
              ProductBadge(
                Leg(
                  [],
                  id: '',
                  lineName: 'E 1',
                  product: Product.regional,
                ),
              ),
            ],
          ),
          Text(
            AppLocalizations.of(context)!.trainCategoriesContent4,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  void _showDataSources(BuildContext context) {
    _showDialog(
      context: context,
      titleText: AppLocalizations.of(context)!.dataSources,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.thirdExpertDraft,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          TextButton(
            onPressed: () {
              launchUrl(Uri.parse(
                  "https://fragdenstaat.de/anfrage/maschinenlesbarer-deutschland-takt/"));
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: Text(AppLocalizations.of(context)!.transportMinistry),
          ),
          SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.corrections,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          TextButton(
            onPressed: () {
              launchUrl(Uri.parse(
                  "https://gist.github.com/TheMinefighter/1ed90508f3fff466c43869c1b394b243"));
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: Text("Tobias Brohl via GitHub"),
          ),
          SizedBox(height: 10),
          Text(
            "Haltestellendaten",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Row(
            children: [
              Text("Deutsche Bahn AG"),
              TextButton(
                onPressed: () {
                  launchUrl(Uri.parse(
                      "https://creativecommons.org/licenses/by/4.0/"));
                },
                child: Text(
                  "CC-BY 4.0",
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.osmStationData,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          TextButton(
            onPressed: () {
              launchUrl(Uri.parse("https://www.openstreetmap.org/copyright"));
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: Text(AppLocalizations.of(context)!.osmContributors),
          )
        ],
      ),
    );
  }

  void _showLegal(BuildContext context) {
    _showDialog(
      context: context,
      titleText: AppLocalizations.of(context)!.imprint,
      additionalActions: [
        TextButton(
          onPressed: () {
            showLicensePage(context: context);
          },
          child:
              Text(MaterialLocalizations.of(context).viewLicensesButtonLabel),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Environment.imprintAddress),
          SizedBox(height: 10),
          Text(
              "${AppLocalizations.of(context)!.contact} ${Environment.imprintEmail}"),
          SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.privacy,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            AppLocalizations.of(context)!.privacyContent,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  void _showDialog({
    required BuildContext context,
    required String titleText,
    required Widget content,
    List<Widget> additionalActions = const [],
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titleText),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: content,
        ),
        actions: [
          ...additionalActions,
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          )
        ],
      ),
    );
  }
}

class _MotisReference extends StatefulWidget {
  const _MotisReference({
    super.key,
  });

  @override
  State<_MotisReference> createState() => _MotisReferenceState();
}

class _MotisReferenceState extends State<_MotisReference> {
  late TapGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = TapGestureRecognizer()
      ..onTap = () {
        launchUrl(Uri.parse("https://github.com/motis-project/motis"));
      };
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: AppLocalizations.of(context)!.aboutRouting1,
            style: DefaultTextStyle.of(context).style,
          ),
          TextSpan(
            text: "Motis",
            recognizer: _recognizer,
            style: DefaultTextStyle.of(context)
                .style
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          TextSpan(
            text: AppLocalizations.of(context)!.aboutRouting2,
            style: DefaultTextStyle.of(context).style,
          ),
        ],
      ),
    );
  }
}
