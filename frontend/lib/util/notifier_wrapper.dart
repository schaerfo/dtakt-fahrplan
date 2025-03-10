// Copyright 2025 Christian Schärf
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';

class NotifierWrapper<T> extends ChangeNotifier {
  T _value;

  NotifierWrapper(this._value);

  T get value => _value;
  set value(T newValue) {
    _value = newValue;
    notifyListeners();
  }
}
