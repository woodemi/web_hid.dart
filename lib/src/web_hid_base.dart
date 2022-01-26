part of '../web_hid.dart';

class Hid extends Delegate<Object> {
  Hid._(delegate) : super(delegate);

  Future<List<HidDevice>> requestDevice([RequestOptions? options]) {
    var promise =
        callMethod('requestDevice', [options ?? RequestOptions(filters: [])]);
    return promiseToFuture(promise).then((value) {
      return (value as List).map((e) => HidDevice._(e)).toList();
    });
  }

  Future<List<HidDevice>> getDevices() {
    var promise = callMethod('getDevices');
    return promiseToFuture(promise).then((value) {
      return (value as List).map((e) => HidDevice._(e)).toList();
    });
  }
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
