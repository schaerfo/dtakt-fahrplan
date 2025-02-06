import 'package:flutter/widgets.dart';

import '../models/types.dart';

class SearchParameters extends ChangeNotifier {
  Station? _from;
  Station? _to;
  var _mode = Mode.all;
  var _anchor = TimeAnchor.depart;

  Station? get from => _from;
  Station? get to => _to;
  get mode => _mode;
  get anchor => _anchor;

  set anchor(value) {
    _anchor = value;
    notifyListeners();
  }

  set mode(value) {
    _mode = value;
    notifyListeners();
  }

  void setTo(Station value) {
    _to = value;
    notifyListeners();
  }

  void setFrom(Station value) {
    _from = value;
    notifyListeners();
  }
}
