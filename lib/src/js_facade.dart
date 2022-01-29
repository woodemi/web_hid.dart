@JS()
library js_facade;

import 'dart:js_util' as js_util;

import 'package:js/js.dart';

abstract class Delegate<T extends Object> {
  final T _delegate;

  T get delegate => _delegate;

  Delegate(this._delegate);

  Prop getProperty<Prop>(String name) => js_util.getProperty(_delegate, name);

  Result callMethod<Result>(String method, [List<Object> args = const []]) => js_util.callMethod(_delegate, method, args);
}

/// FIXME https://github.com/flutter/flutter/issues/97357
/// Dummy class for type inference
abstract class Interop {}

abstract class InteropWrapper<T extends Interop> {}