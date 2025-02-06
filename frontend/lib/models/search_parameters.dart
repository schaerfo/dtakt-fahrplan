import 'package:flutter/widgets.dart';

import '../models/types.dart';
import '../util/notifier_wrapper.dart';

class SearchParameters extends ChangeNotifier {
  Station? _from;
  Station? _to;

  Station? get from => _from;
  Station? get to => _to;

  void setTo(Station value) {
    _to = value;
    notifyListeners();
  }

  void setFrom(Station value) {
    _from = value;
    notifyListeners();
  }
}

typedef ModeNotifier = NotifierWrapper<Mode>;
typedef TimeAnchorNotifier = NotifierWrapper<TimeAnchor>;
