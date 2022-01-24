// ignore_for_file: avoid_print, avoid_web_libraries_in_flutter

import 'dart:html' show EventListener;
import 'dart:js' show allowInterop;
import 'dart:js_util' show getProperty;
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_hid/web_hid.dart';

final ledgerDeviceIds = RequestOptionsFilter(
  vendorId: 0x2c97,
);

Uint8List transport(
  int cla,
  int ins,
  int p1,
  int p2, [
  Uint8List? data,
]) {
  data ??= Uint8List.fromList([]);
  return Uint8List.fromList([cla, ins, p1, p2, data.length, ...data]);
}

final getAppAndVersion = transport(0xb0, 0x01, 0x00, 0x00);

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
            _buildSendReport(),
            _buildSubscribeInputReport(),
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

  Widget _buildSendReport() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: const Text('device.sendReport getAppAndVersion'),
          onPressed: () {
            var blockBytes = makeBlock(getAppAndVersion);
            _device?.sendReport(0, blockBytes).then((value) {
              print('device.sendReport getAppAndVersion success');
            }).catchError((error) {
              print('device.sendReport getAppAndVersion $error');
            });
          },
        ),
      ],
    );
  }

  Widget _buildSubscribeInputReport() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: const Text('device.subscribeInputReport'),
          onPressed: () {
            _device?.subscribeInputReport(_handleInputReport);
            print('device.subscribeInputReport success');
          },
        ),
        ElevatedButton(
          child: const Text('device.unsubscribeInputReport'),
          onPressed: () {
            _device?.unsubscribeInputReport(_handleInputReport);
            print('device.unsubscribeInputReport success');
          },
        ),
      ],
    );
  }

  final EventListener _handleInputReport = allowInterop((event) {
    ByteData blockData = getProperty(event, 'data');
    var data = parseBlock(blockData);

    var readBuffer = ReadBuffer(data.buffer.asByteData());
    assert(readBuffer.getUint8() == 1);
    var nameLength = readBuffer.getUint8();
    var name = String.fromCharCodes(readBuffer.getUint8List(nameLength));
    var versionLength = readBuffer.getUint8();
    var version = String.fromCharCodes(readBuffer.getUint8List(versionLength));
    print('$name, $version');
  });
}

const packetSize = 64;
final channel = Random().nextInt(0xffff);
const Tag = 0x05;

/// 
/// +---------+--------+------------+-----------+
/// | channel |  Tag   | blockSeqId | blockData |
/// +---------+--------+------------+-----------+
/// | 2 bytes | 1 byte | 2 bytes    |       ... |
/// +---------+--------+------------+-----------+
Uint8List makeBlock(Uint8List apdu) {
  // TODO Multiple blocks

  var apduBuffer = WriteBuffer();
  apduBuffer.putUint16(apdu.length, endian: Endian.big);
  apduBuffer.putUint8List(apdu);
  var blockSize = packetSize - 5;
  var paddingLength = blockSize - apdu.length - 2;
  apduBuffer.putUint8List(Uint8List.fromList(List.filled(paddingLength, 0)));
  var apduData = apduBuffer.done();

  var writeBuffer = WriteBuffer();
  writeBuffer.putUint16(channel, endian: Endian.big);
  writeBuffer.putUint8(Tag);
  writeBuffer.putUint16(0, endian: Endian.big);
  writeBuffer.putUint8List(apduData.buffer.asUint8List());
  return writeBuffer.done().buffer.asUint8List();
}

Uint8List parseBlock(ByteData block) {
  var readBuffer = ReadBuffer(block);
  assert(readBuffer.getUint16(endian: Endian.big) == channel);
  assert(readBuffer.getUint8() == Tag);
  assert(readBuffer.getUint16(endian: Endian.big) == 0);

  var dataLength = readBuffer.getUint16(endian: Endian.big);
  var data = readBuffer.getUint8List(dataLength);

  return Uint8List.fromList(data);
}