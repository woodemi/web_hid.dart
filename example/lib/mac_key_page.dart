// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_hid/web_hid.dart';

final keyboardBacklightIds = RequestOptionsFilter(
  vendorId: 0x05ac,
  usage: 0x0f,
  usagePage: 0xff00,
);

class MacKeyPage extends StatefulWidget {
  const MacKeyPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MacKeyState();
}

class _MacKeyState extends State<MacKeyPage> {
  HidDevice? _device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mac Key Conf'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              child: const Text('canUse'),
              onPressed: () {
                bool canUse = canUseHid();
                print('canUse $canUse');
              },
            ),
            _buildRequestGet(),
            _buildOpenClose(),
            _buildSendReport(),
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
              filters: [keyboardBacklightIds],
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

  Widget _buildSendReport() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: const Text('device.sendFeatureReport 0'),
          onPressed: () {
            _device?.sendFeatureReport(1, Uint32List.fromList([1, 0])).then((value) {
              print('device.sendFeatureReport 0 success');
            }).catchError((error) {
              print('device.sendFeatureReport $error');
            });
          },
        ),
        ElevatedButton(
          child: const Text('device.sendFeatureReport 512'),
          onPressed: () {
            _device?.sendFeatureReport(1, Uint32List.fromList([512, 0])).then((value) {
              print('device.sendFeatureReport 512 success');
            }).catchError((error) {
              print('device.sendFeatureReport $error');
            });
          },
        ),
      ],
    );
  }
}
