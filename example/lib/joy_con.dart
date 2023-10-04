
import 'dart:typed_data';
import 'package:web_hid/web_hid.dart';

class JoyCon {
  final HidDevice device;
  Function(Uint8List) onInputReport;
  JoyCon({required this.device, required this.onInputReport});

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

  Future<void> getRequestDeviceInfo() async{
    const outputReportID = 0x01;
    const subcommand = [0x02];
    const data = [
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      ...subcommand,
    ];
    await device.sendReport(outputReportID, Uint8List.fromList(data));
  }

  Future<void> getBatteryLevel() async{
    const outputReportID = 0x01;
    const subCommand = [0x50];
    const data = [
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      ...subCommand,
    ];
    await device.sendReport(outputReportID, Uint8List.fromList(data));
  }

  Future<void> enableUSBHIDJoystickReport() async{
    // bool isUSB = false;
    List<dynamic> collections = device.getProperty('collections');
    if(collections.isEmpty){
      return;
    }
    // print(collections[0]);
    // var tmp = collections[0].getProperty('outputReports');
    // print(tmp);
    // TODO fix
    // const usb =
    //     this.device.collections[0].outputReports.find(
    //             (r) => r.reportId == 0x80
    //     ) != null;
    // if (isUSB) {
    //   await device.sendReport(0x80, Uint8List.fromList([0x01]));
    //   await device.sendReport(0x80, Uint8List.fromList([0x02]));
    //   await device.sendReport(0x01, Uint8List.fromList([0x03]));
    //   await device.sendReport(0x80, Uint8List.fromList([0x04]));
    // }
  }

  Future<void> enableSimpleHIDMode() async{
    const outputReportID = 0x01;
    const subcommand = [0x03, 0x3f];
    const data = [
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      ...subcommand,
    ];
    await device.sendReport(outputReportID, Uint8List.fromList(data));
  }

  Future<void> enableStandardFullMode() async{
    const outputReportID = 0x01;
    const subcommand = [0x03, 0x30];
    const data = [
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      ...subcommand,
    ];
    await device.sendReport(outputReportID, Uint8List.fromList(data));
  }
  Future<void> enableIMUMode() async{
    const outputReportID = 0x01;
    const subcommand = [0x40, 0x01];
    const data = [
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      ...subcommand,
    ];
    await device.sendReport(outputReportID, Uint8List.fromList(data));
  }

  Future<void> disableIMUMode() async{
    const outputReportID = 0x01;
    const subcommand = [0x40, 0x00];
    const data = [
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      ...subcommand,
    ];
    await device.sendReport(outputReportID, Uint8List.fromList(data));
  }

  Future<void> enableVibration() async{
    const outputReportID = 0x01;
    const subcommand = [0x48, 0x01];
    const data = [
      0x00,
      0x00,
      0x01,
      0x40,
      0x40,
      0x00,
      0x01,
      0x40,
      0x40,
      ...subcommand,
    ];
    await device.sendReport(outputReportID, Uint8List.fromList(data));
  }

  Future<void> disableVibration() async{
    const outputReportID = 0x01;
    const subcommand = [0x48, 0x00];
    const data = [
      0x00,
      0x00,
      0x01,
      0x40,
      0x40,
      0x00,
      0x01,
      0x40,
      0x40,
      ...subcommand,
    ];
    await device.sendReport(outputReportID, Uint8List.fromList(data));
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
