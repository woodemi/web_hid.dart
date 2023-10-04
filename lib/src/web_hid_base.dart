part of '../web_hid.dart';

class Hid extends Delegate<EventTarget> {
  Hid._(EventTarget delegate) : super(delegate);
  late EventListener _connectListener;
  late EventListener _disconnectListener;

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

  void subscribeConnect(Function(HidDevice) listener) {
    _connectListener = allowInterop((event){
      var e = getObjectProperty(event, 'device');
      listener(HidDevice._(e));
    });
    setProperty('onconnect', _connectListener);
  }

  void unsubscribeConnect(Function() listener) {
    setProperty('onconnect', null);
    listener();
  }

  void subscribeDisconnect(Function(HidDevice) listener) {
    _disconnectListener = allowInterop((event){
      var e = getObjectProperty(event, 'device');
      listener(HidDevice._(e));
    });
    setProperty('ondisconnect', _disconnectListener);
  }

  void unsubscribeDisconnect(Function() listener) {
    setProperty('ondisconnect', null);
    listener();
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
