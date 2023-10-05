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
      var e = getPropertyFrom(event, 'device');
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
      var e = getPropertyFrom(event, 'device');
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

class HidDevice extends Delegate<EventTarget> {
  HidDevice._(EventTarget delegate) : super(delegate);
  late EventListener _eventListener;

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

  void subscribeInputReport(Function(Uint8List) listener) {
    _eventListener = allowInterop((Event event) {
      ByteData blockData = getPropertyFrom(event, 'data');
      var reportId = getPropertyFrom(event, 'reportId');

      List<int> dataList = [reportId];
      dataList.addAll(blockData.buffer.asUint8List());
      listener(Uint8List.fromList(dataList));
    });
    setProperty('oninputreport', _eventListener);
  }

  void unsubscribeInputReport(Function() listener) {
    setProperty('oninputreport', null);
    listener();
  }

  Future<void> sendFeatureReport(int requestId, TypedData data) {
    var promise = callMethod('sendFeatureReport', [requestId, data]);
    return promiseToFuture(promise);
  }
}
