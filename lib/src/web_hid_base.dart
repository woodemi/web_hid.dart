part of '../web_hid.dart';

class Hid implements InteropWrapper<_Hid> {
  final _Hid _interop;

  Hid._(this._interop);

  Future<List<HidDevice>> requestDevice([RequestOptions? options]) {
    var promise = _interop.requestDevice(options ?? RequestOptions(filters: []));
    return promiseToFuture(promise).then((value) {
      return (value as List).map((e) => HidDevice._(e)).toList();
    });
  }

  Future<List<HidDevice>> getDevices() {
    var promise = _interop.getDevices();
    return promiseToFuture(promise).then((value) {
      return (value as List).map((e) => HidDevice._(e)).toList();
    });
  }

  /// FIXME allowInterop
  void subscribeConnect(EventListener listener) {
    _interop.addEventListener('connect', listener);
  }

  /// FIXME allowInterop
  void unsubscribeConnect(EventListener listener) {
    _interop.removeEventListener('connect', listener);
  }

  /// FIXME allowInterop
  void subscribeDisconnect(EventListener listener) {
    _interop.addEventListener('disconnect', listener);
  }

  /// FIXME allowInterop
  void unsubscribeDisconnect(EventListener listener) {
    _interop.removeEventListener('disconnect', listener);
  }
}

@JS('HID')
class _Hid implements Interop {
  /// https://developer.mozilla.org/en-US/docs/Web/API/HID/requestDevice
  external Object requestDevice(Object options);

  /// https://developer.mozilla.org/en-US/docs/Web/API/HID/getDevices
  external Object getDevices();

  /// https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener
  external void addEventListener(String type, EventListener? listener, [bool? useCapture]);

  /// https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/removeEventListener
  external void removeEventListener(String type, EventListener? listener, [bool? useCapture]);
}

@JS()
@anonymous
class RequestOptions {
  external factory RequestOptions({
    required List<dynamic> filters,
  });
}

@JS()
@anonymous
class RequestOptionsFilter {
  external factory RequestOptionsFilter({
    int vendorId,
    int productId,
    int usage,
    int usagePage,
  });
}

class HidDevice extends Delegate<EventTarget> {
  HidDevice._(EventTarget delegate) : super(delegate);

  Future<void> open() {
    var promise = callMethod('open');
    return promiseToFuture(promise);
  }

  Future<void> close() {
    var promise = callMethod('close');
    return promiseToFuture(promise);
  }

  bool get opened => getProperty('opened');

  Future<void> sendReport(int requestId, TypedData data) {
    var promise = callMethod('sendReport', [requestId, data]);
    return promiseToFuture(promise);
  }

  /// FIXME allowInterop
  void subscribeInputReport(EventListener listener) {
    delegate.addEventListener('inputreport', listener);
  }

  /// FIXME allowInterop
  void unsubscribeInputReport(EventListener listener) {
    delegate.removeEventListener('inputreport', listener);
  }

  Future<void> sendFeatureReport(int requestId, TypedData data) {
    var promise = callMethod('sendFeatureReport', [requestId, data]);
    return promiseToFuture(promise);
  }
}
