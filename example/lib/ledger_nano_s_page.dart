// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:web_hid/web_hid.dart';

final ledgerDeviceIds = RequestOptionsFilter(
  vendorId: 0x2c97,
);

class LedgerNanoSPage extends StatefulWidget {
  const LedgerNanoSPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LedgerNanoSState();
  }
}

class _LedgerNanoSState extends State<LedgerNanoSPage> {
  HidDevice? _device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger Nano S'),
      ),
      body: Center(
        child: Column(
          children: [
            _buildRequestGet(),
            _buildOpenClose(),
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
              filters: [ledgerDeviceIds],
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
}