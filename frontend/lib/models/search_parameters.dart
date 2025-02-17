import 'package:flutter/material.dart';

import '../models/types.dart';
import '../util/notifier_wrapper.dart';

class EndpointNotifier extends ChangeNotifier {
  Station? _from;
  Station? _to;

  Station? get from => _from;
  Station? get to => _to;
  bool get bothEndpointsSet => from != null && to != null;

  void setTo(Station value) {
    _to = value;
    notifyListeners();
  }

  void setFrom(Station value) {
    _from = value;
    notifyListeners();
  }

  void swap() {
    Station? tmp = _from;
    _from = _to;
    _to = tmp;
    notifyListeners();
  }
}

typedef ModeNotifier = NotifierWrapper<Mode>;
typedef TimeAnchorNotifier = NotifierWrapper<TimeAnchor>;
typedef TimeNotifier = NotifierWrapper<TimeOfDay>;
