<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

Dart wrapper via `dart:js` for https://wicg.github.io/webhid/

## Features

- canUseHid
- getDevices/requestDevice
- open/close
- sendFeatureReport

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

### sendFeatureReport

```dart
_device?.sendFeatureReport(1, Uint32List.fromList([1, 0])).then((value) {
  print('device.sendFeatureReport 0 success');
}).catchError((error) {
  print('device.sendFeatureReport $error');
});
```

## Additional information

Status in Chromium: https://chromestatus.com/feature/5172464636133376
