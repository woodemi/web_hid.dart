@JS()
library web_hid;

import 'dart:html' show EventTarget, EventListener;
import 'dart:js_util' show promiseToFuture;

import 'package:js/js.dart';

import 'src/js_facade.dart';

part 'src/web_hid_base.dart';

@JS('navigator.hid')
external EventTarget? get _hid;

bool canUseHid() => _hid != null;

Hid? _instance;
Hid get hid {
  if (_hid != null) {
    return _instance ??= Hid._(_hid);
  }
  throw 'navigator.hid unavailable';
}
