// ignore_for_file: avoid_print
import 'dart:typed_data';
import 'package:web_hid/web_hid.dart';

class JoyConCore {
  final HidDevice device;
  Function(HIDInputReportEvent) onInputReport;
  JoyConCore({required this.device, required this.onInputReport});

  Future<void> open()async {
    if (!device.opened) {
      await device.open();
    }
    device.subscribeInputReport(onInputReport);
  }

  Future<void> close()async {
    if (device.opened) {
      await device.close();
    }
    device.unsubscribeInputReport((){
      print('unsubscribeInputReport finish');
    });
  }

  Future<void> setLEDState(bool led1, bool led2, bool led3, bool led4) async{
    int n = 0x00;
    // LEDState
    n |= led1?0x1:0x0; // 0x1: player 1 light on/off
    n |= led2?0x2:0x0; // 0x2: player 1 light on/off
    n |= led3?0x4:0x0; // 0x4: player 1 light on/off
    n |= led4?0x8:0x0; // 0x8: player 1 light on/off
    // 0x10: flash player 1 light on/off
    // 0x20: flash player 2 light on/off
    // 0x40: flash player 3 light on/off
    // 0x80: flash player 4 light on/off
    const outputReportID = 0x01;
    var subcommand = [0x30, n];
    var data = [
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      ...subcommand
    ];

    await device.sendReport(outputReportID, Uint8List.fromList(data));
  }
}
