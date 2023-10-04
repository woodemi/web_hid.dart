part of '../web_hid.dart';

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
      ByteData blockData = getObjectProperty(event, 'data');
      var reportId = getObjectProperty(event, 'reportId');

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
