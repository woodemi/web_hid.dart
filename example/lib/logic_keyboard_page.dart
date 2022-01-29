// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_hid/web_hid.dart';

final k380keyboardIds = RequestOptionsFilter(
  vendorId: 0x046D,
  usagePage: 0xFF00,
);

final k380_seq_fkeys_on =
    Uint8List.fromList([0x10, 0xff, 0x0b, 0x1e, 0x00, 0x00, 0x00]);
final k380_seq_fkeys_off =
    Uint8List.fromList([0x10, 0xff, 0x0b, 0x1e, 0x01, 0x00, 0x00]);

class LogicKeyboardPage extends StatefulWidget {
  const LogicKeyboardPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LogicKeyboardPageState();
}

class _LogicKeyboardPageState extends State<LogicKeyboardPage> {
  HidDevice? _device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logic Keyboard Conf'),
      ),
      body: Center(
        child: Column(
          children: [
            _buildRequestGet(),
            _buildOpenClose(),
            _buildSendFeatureReport(),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestGet() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: const Text('requestDevice'),
          onPressed: () async {
            List<HidDevice> requestDevice = await hid.requestDevice(RequestOptions(
              filters: [k380keyboardIds],
            ));
            print('requestDevice $requestDevice');
            _device = requestDevice[0];
          },
        ),
        ElevatedButton(
          child: const Text('getDevices'),
          onPressed: () async {
            List<HidDevice> getDevices = await hid.getDevices();
            print('getDevices $getDevices');
            _device = getDevices[0];
          },
        ),
      ],
    );
  }

  Widget _buildOpenClose() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: const Text('device.open'),
          onPressed: () {
            _device?.open().then((value) {
              print('device.open success');
            }).catchError((error) {
              print('device.open $error');
            });
          },
        ),
        ElevatedButton(
          child: const Text('device.close'),
          onPressed: () {
            _device?.close().then((value) {
              print('device.close success');
            }).catchError((error) {
              print('device.close $error');
            });
          },
        ),
      ],
    );
  }

  Widget _buildSendFeatureReport() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: const Text('device.sendFeatureReport on'),
          onPressed: () {
            _device?.sendReport(0, k380_seq_fkeys_on).then((value) {
              print('device.sendReport on success');
            }).catchError((error) {
              print('device.sendReport on $error');
            });
          },
        ),
        ElevatedButton(
          child: const Text('device.sendFeatureReport off'),
          onPressed: () {
            _device?.sendReport(0, k380_seq_fkeys_off).then((value) {
              print('device.sendReport off success');
            }).catchError((error) {
              print('device.sendReport off $error');
            });
          },
        ),
      ],
    );
  }
}
