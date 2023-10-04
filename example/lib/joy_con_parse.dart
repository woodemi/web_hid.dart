
import 'dart:typed_data';
class JoyConDeviceInfo{
  final int versionMajor;
  final int versionMinor;
  final int type;
  final String macAddress;
  final bool spiColorInUse;

  JoyConDeviceInfo({
    this.versionMajor = 0,
    this.versionMinor = 0,
    this.type = 0, this.macAddress = 'Unknown',
    this.spiColorInUse = false
  });
}

class JoyConBatteryState{
  final int batteryLevel;
  final bool isCharging;

  JoyConBatteryState({
    this.batteryLevel = 0,
    this.isCharging = false,
  });
}

class JoyConButtonState{
  final bool buttonX;
  final bool buttonY;
  final bool buttonA;
  final bool buttonB;
  final bool buttonR;
  final bool buttonZR;
  final bool buttonDown;
  final bool buttonUp;
  final bool buttonRight;
  final bool buttonLeft;
  final bool buttonL;
  final bool buttonZL;
  final bool buttonSR;
  final bool buttonSL;
  final bool buttonPlus;
  final bool buttonMinus;
  final bool buttonRightStick;
  final bool buttonLeftStick;
  final bool buttonHome;
  final bool buttonCapture;
  final bool chargingGrip;
  JoyConButtonState({
    this.buttonX = false,
    this.buttonY = false,
    this.buttonA = false,
    this.buttonB = false,
    this.buttonR = false,
    this.buttonZR = false,
    this.buttonDown = false,
    this.buttonUp = false,
    this.buttonRight = false,
    this.buttonLeft = false,
    this.buttonL = false,
    this.buttonZL = false,
    this.buttonSR = false,
    this.buttonSL = false,
    this.buttonPlus = false,
    this.buttonMinus = false,
    this.buttonRightStick = false,
    this.buttonLeftStick = false,
    this.buttonHome = false,
    this.buttonCapture = false,
    this.chargingGrip = false,
  });
}

class JoyConStickState{
  final double posX;
  final double posY;

  JoyConStickState({
    this.posX = 0.0,
    this.posY = 0.0
  });
}

class JoyConAccelerometers{
  final double x;
  final double y;
  final double z;

  JoyConAccelerometers({
    this.x = 0.0,
    this.y = 0.0,
    this.z = 0.0
  });

  factory JoyConAccelerometers.fromValue(int x, int y, int z){
    return JoyConAccelerometers(
      x:double.parse((0.000244 * x).toStringAsFixed(6)),
      y:double.parse((0.000244 * y).toStringAsFixed(6)),
      z:double.parse((0.000244 * z).toStringAsFixed(6)),
    );
  }

  factory JoyConAccelerometers.fromByteData(ByteData data){
    return JoyConAccelerometers(
      x:double.parse((0.000244 * data.getInt16(0, Endian.little)).toStringAsFixed(6)),
      y:double.parse((0.000244 * data.getInt16(2, Endian.little)).toStringAsFixed(6)),
      z:double.parse((0.000244 * data.getInt16(4, Endian.little)).toStringAsFixed(6)),
    );
  }
}

class JoyConGyroscopes{
  final double dps; // Degrees Per Second
  final double rps; // Revolutions Per Second

  JoyConGyroscopes({
    this.dps = 0.0,
    this.rps = 0.0
  });

  factory JoyConGyroscopes.fromByteData(ByteData data){
    int value = data.getInt16(0, Endian.little);
    return JoyConGyroscopes(
      dps: double.parse((0.06103 * value).toStringAsFixed(6)),
      rps: double.parse((0.0001694 * value).toStringAsFixed(6)),
    );
  }
}

class JoyConHIDParse {
  JoyConDeviceInfo parseDeviceInfo(Uint8List data) {
    // subcommand 0x2
    // Byte
    // 0-1	Firmware Version. Latest is 3.89 (from 5.0.0 and up).
    // 2		1=Left Joy-Con, 2=Right Joy-Con, 3=Pro Controller.
    // 3		Unknown. Seems to be always 02
    // 4-9	Joy-Con MAC address in Big Endian
    // 10		Unknown. Seems to be always 01
    // 11	  If 01, colors in SPI are used. Otherwise default ones.
    var subData = data.sublist(15, 15 + 11);
    return JoyConDeviceInfo(
      versionMajor: subData[0],
      versionMinor: subData[0],
      type: subData[2],
      macAddress: subData.sublist(4,10).map((e) => e.toRadixString(16).toUpperCase().padLeft(2, '0')).join(":"),
      spiColorInUse: data[11] == 0x1
    );
  }

  int parseInputReportID(Uint8List data) {
    return data[0];
  }

  int parseTimer(Uint8List data) {
    return data[1];
  }

  JoyConBatteryState parseBatteryLevel(Uint8List data){
    // Byte 2 high nibble
    var level = data[2] >> 4 ;
    return JoyConBatteryState(
      batteryLevel: level & 0xE,
      isCharging: level & 0x1 != 0,
    );
  }

  int parseConnectionInfo(Uint8List data) {
    // (con_info >> 1) & 3 - 3=JC, 0=Pro/ChrGrip. con_info & 1 - 1=Switch/USB powered.
    return data[2] & 0xF;
  }

  JoyConButtonState parseCompleteButtonStatus(Uint8List data) {
    var buttonStatus = JoyConButtonState(
      // Byte 3 (Right Joy-Con)
      buttonY: 0x01 & data[3] != 0,
      buttonX: 0x02 & data[3] != 0,
      buttonB: 0x04 & data[3] != 0,
      buttonA: 0x08 & data[3] != 0,
      buttonR: 0x40 & data[3] != 0,
      buttonZR: 0x80 & data[3] != 0,
      // Byte 5 (Left Joy-Con)
      buttonDown: 0x01 & data[5] != 0,
      buttonUp: 0x02 & data[5] != 0,
      buttonRight: 0x04 & data[5] != 0,
      buttonLeft: 0x08 & data[5] != 0,
      buttonL: 0x40 & data[5] != 0,
      buttonZL: 0x80 & data[5] != 0,
      // Byte 3,5 (Shared)
      buttonSR: 0x10 & (data[3] | data[5]) != 0,
      buttonSL: 0x20 & (data[3] | data[5]) != 0,
      // Byte 4 (Shared)
      buttonMinus: 0x01 & data[4] != 0,
      buttonPlus: 0x02 & data[4] != 0,
      buttonLeftStick: 0x08 & data[4] != 0,
      buttonRightStick: 0x04 & data[4] != 0,
      buttonHome: 0x10 & data[4] != 0,
      buttonCapture: 0x20 & data[4] != 0,
    );
    return buttonStatus;
  }

  JoyConStickState parseAnalogStickLeft(Uint8List data, int calX, int calY) {
    var horizontal = data[6] | ((data[7] & 0xf) << 8);
    var vertical = ((data[7] >> 4) | (data[8] << 4)) * -1;
    // print('horizontal:$horizontal vertical:$vertical');
    return JoyConStickState(
      posX: double.parse(((horizontal / calX - 1) * 2).toStringAsFixed(2)),
      posY: double.parse(((vertical / calY + 1) * 2).toStringAsFixed(2)),
    );
  }

  JoyConStickState parseAnalogStickRight(Uint8List data, int calX, int calY) {
    var horizontal = data[9] | ((data[10] & 0xf) << 8);
    var vertical = ((data[10] >> 4) | (data[11] << 4)) * -1;
    // print('horizontal:$horizontal vertical:$vertical');
    return JoyConStickState(
      posX: double.parse(((horizontal / calX - 1) * 2).toStringAsFixed(2)),
      posY: double.parse(((vertical / calY + 1) * 2).toStringAsFixed(2)),
    );
  }

  List<JoyConAccelerometers> parseAccelerometers(Uint8List data) {
    return [
      JoyConAccelerometers.fromByteData(data.sublist(13,19).buffer.asByteData()),
      JoyConAccelerometers.fromByteData(data.sublist(25,31).buffer.asByteData()),
      JoyConAccelerometers.fromByteData(data.sublist(37,43).buffer.asByteData()),
    ];
  }
  List<List<JoyConGyroscopes>> parseGyroscopes(Uint8List data){
    return[
      [
        JoyConGyroscopes.fromByteData(data.sublist(19,21).buffer.asByteData()),
        JoyConGyroscopes.fromByteData(data.sublist(21,23).buffer.asByteData()),
        JoyConGyroscopes.fromByteData(data.sublist(23,25).buffer.asByteData()),
      ],
      [
        JoyConGyroscopes.fromByteData(data.sublist(31,33).buffer.asByteData()),
        JoyConGyroscopes.fromByteData(data.sublist(33,35).buffer.asByteData()),
        JoyConGyroscopes.fromByteData(data.sublist(35,37).buffer.asByteData()),
      ],
      [
        JoyConGyroscopes.fromByteData(data.sublist(43,45).buffer.asByteData()),
        JoyConGyroscopes.fromByteData(data.sublist(45,47).buffer.asByteData()),
        JoyConGyroscopes.fromByteData(data.sublist(47,49).buffer.asByteData()),
      ]
    ];
  }
}