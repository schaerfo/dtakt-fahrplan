// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';

import 'dart:async';

import '../backend/motis_client.dart';
import '../models/types.dart';

const Duration debounceDuration = Duration(milliseconds: 500);

class LocationInput extends StatefulWidget {
  final String label;
  final Station? initialValue;
  final void Function(Station) onSelected;

  const LocationInput({
    required this.label,
    this.initialValue,
    required this.onSelected,
    super.key,
  });

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  // The query currently being searched for. If null, there is no pending
  // request.
  String? _currentQuery;
  final _controller = SearchController();
  final _client = MotisClient();

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
    _updateValue();
  }

  @override
  void didUpdateWidget(LocationInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateValue();
  }

  void _updateValue() {
    if (widget.initialValue != null) {
      // Avoid updating the search controller immediately after a search result
      // has been selected
      if (widget.initialValue!.name != _controller.text) {
        _controller.text = widget.initialValue!.name;
      }
    } else {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SearchAnchor.bar(
        barHintText: widget.label,
        searchController: _controller,
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
                widget.onSelected(item);
              },
            );
          }));
          return _lastStations;
        },
      ),
    );
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
