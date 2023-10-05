Dart wrapper via `dart:js` for https://wicg.github.io/webhid/

## Features

- [canUseHid](#canusehid)
- [getDevices/requestDevice](#getdevicesrequestdevice)
- [subscribeConnect/unsubscribeConnect](#subscribeconnectunsubscribeconnect)
- [subscribeDisconnect/unsubscribeDisconnect](#subscribedisconnectunsubscribedisconnect)
- [open/close](#openclose)
- [sendReport](#sendreport)
- [subscribeInputReport/unsubscribeInputReport](#subscribeinputreportunsubscribeinputreport)
- [sendFeatureReport](#sendfeaturereport)

## Usage

### canUseHid

```dart
bool canUse = canUseHid();
print('canUse $canUse');
```

### getDevices/requestDevice

- https://developer.mozilla.org/en-US/docs/Web/API/HID/getDevices

```dart
List<HidDevice> getDevices = await hid.getDevices();
_device = getDevices[0];
```

- https://developer.mozilla.org/en-US/docs/Web/API/HID/requestDevice

```dart
List<HidDevice> requestDevice = await hid.requestDevice(RequestOptions(
  filters: [keyboardBacklightIds],
));
_device = requestDevice[0];
```

### subscribeConnect/unsubscribeConnect

https://developer.mozilla.org/en-US/docs/Web/API/HID/onconnect

```dart
hid.subscribeConnect((device){
  print('HID connected: ${device.getProperty('productName')}');
});
...
hid.unsubscribeConnect((){
  print('hid.unsubscribeConnect finish');
});
```

### subscribeDisconnect/unsubscribeDisconnect

https://developer.mozilla.org/en-US/docs/Web/API/HID/ondisconnect

```dart
hid.subscribeDisconnect((device){
  print('HID disconnected: ${device.getProperty('productName')}');
});
...
hid.unsubscribeDisconnect((){
  print('hid.unsubscribeDisconnect finish');
});
```

### open/close

- https://developer.mozilla.org/en-US/docs/Web/API/HIDDevice/open

```dart
_device?.open().then((value) {
  print('device.open success');
}).catchError((error) {
  print('device.open $error');
});
```

- https://developer.mozilla.org/en-US/docs/Web/API/HIDDevice/close

```dart
_device?.close().then((value) {
  print('device.close success');
}).catchError((error) {
  print('device.close $error');
});
```

### sendReport

https://developer.mozilla.org/en-US/docs/Web/API/HIDDevice/sendReport

```dart
_device?.sendReport(0, blockBytes).then((value) {
  print('device.sendReport success');
}).catchError((error) {
  print('device.sendReport $error');
});
```

### subscribeInputReport/unsubscribeInputReport

https://developer.mozilla.org/en-US/docs/Web/API/HIDDevice/oninputreport

```dart
_device?.subscribeInputReport((data) {
  print('_device?.subscribeInputReport receive');
});
...
_device?.unsubscribeInputReport((){
  print('_device?.unsubscribeInputReport finish');
});
```

### sendFeatureReport

https://developer.mozilla.org/en-US/docs/Web/API/HIDDevice/sendFeatureReport

```dart
_device?.sendFeatureReport(1, Uint32List.fromList([1, 0])).then((value) {
  print('device.sendFeatureReport 0 success');
}).catchError((error) {
  print('device.sendFeatureReport $error');
});
```

## Additional information

Status in Chromium: https://chromestatus.com/feature/5172464636133376
