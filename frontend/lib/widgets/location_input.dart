import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:js_interop';

import 'dart:async';
import 'package:http/http.dart' as http;

import '../models/types.dart';

const Duration debounceDuration = Duration(milliseconds: 500);

class LocationInput extends StatefulWidget {
  final String label;

  const LocationInput({
    required this.label,
    super.key,
  });

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  // The query currently being searched for. If null, there is no pending
  // request.
  String? _currentQuery;
  final _client = _MotisClient();

  // The most recent suggestions received from the API.
  late Iterable<Widget> _lastStations = <Widget>[];

  late final _Debounceable<Iterable<Station>?, String> _debouncedSearch;

  // Calls the API to search with the given query. Returns null when
  // the call has been made obsolete.
  Future<Iterable<Station>?> _search(String query) async {
    _currentQuery = query;

    // In a real application, there should be some error handling here.
    final Iterable<Station> options =
        await _client.searchLocation(_currentQuery!);

    // If another search happened after this one, throw away these options.
    if (_currentQuery != query) {
      return null;
    }
    _currentQuery = null;

    return options;
  }

  @override
  void initState() {
    super.initState();
    _debouncedSearch = _debounce(_search);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 400,
      ),
      child: SearchAnchor.bar(
        barHintText: widget.label,
        suggestionsBuilder:
            (BuildContext context, SearchController controller) async {
          final Iterable<Station>? stations =
              (await _debouncedSearch(controller.text))?.toList();
          if (stations == null) {
            return _lastStations;
          }
          _lastStations = List.of(stations.map((Station item) {
            return ListTile(
              title: Text(item.name),
              onTap: () {
                controller.closeView(item.name);
              },
            );
          }));
          return _lastStations;
        },
      ),
    );
  }
}

class _MotisClient {
  final _client = http.Client();

  // Searches the options, but injects a fake "network" delay.
  Future<Iterable<Station>> searchLocation(String query) async {
    if (query.isEmpty) {
      return const Iterable<Station>.empty();
    }
    final uri = Uri(
      scheme: 'https',
      host: 'dtakt-fahrplan.v6.rocks',
      path: 'api/v1/geocode',
      queryParameters: {'text': query},
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      print('Error: HTTP status ${response.statusCode}');
      return const Iterable<Station>.empty();
    }
    final parsed = jsonDecode(utf8.decode(response.bodyBytes));
    final result = (parsed as JSArray).toDart.map((station) {
      return Station.fromJson(station as Map<String, dynamic>);
    });
    return result;
  }
}

typedef _Debounceable<S, T> = Future<S?> Function(T parameter);

/// Returns a new function that is a debounced version of the given function.
///
/// This means that the original function will be called only after no calls
/// have been made for the given Duration.
_Debounceable<S, T> _debounce<S, T>(_Debounceable<S, T> function) {
  _DebounceTimer? debounceTimer;

  return (T parameter) async {
    if (debounceTimer != null && !debounceTimer!.isCompleted) {
      debounceTimer!.cancel();
    }
    debounceTimer = _DebounceTimer();
    try {
      await debounceTimer!.future;
    } on _CancelException {
      return null;
    }
    return function(parameter);
  };
}

// A wrapper around Timer used for debouncing.
class _DebounceTimer {
  _DebounceTimer() {
    _timer = Timer(debounceDuration, _onComplete);
  }

  late final Timer _timer;
  final Completer<void> _completer = Completer<void>();

  void _onComplete() {
    _completer.complete();
  }

  Future<void> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  void cancel() {
    _timer.cancel();
    _completer.completeError(const _CancelException());
  }
}

// An exception indicating that the timer was canceled.
class _CancelException implements Exception {
  const _CancelException();
}
