
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:web_hid/web_hid.dart';
import 'joy_con.dart';
import 'joy_con_parse.dart';

final joyConRightDeviceIds = RequestOptionsFilter(
  vendorId: 0x057e,
  productId: 0x2007
);

class JoyConRight extends StatefulWidget{
  const JoyConRight({super.key});

  @override
  State<StatefulWidget> createState() => _JoyConRightState();
}

class _JoyConRightState extends State<JoyConRight>{
  JoyCon? _joyCon;
  final parse = JoyConHIDParse();
  bool _isConnect = false;
  bool _buttonZR = false;
  bool _buttonR = false;
  bool _buttonSL = false;
  bool _buttonSR = false;
  bool _buttonY = false;
  bool _buttonX = false;
  bool _buttonB = false;
  bool _buttonA = false;
  bool _buttonPlus = false;
  bool _buttonRightStick = false;
  bool _buttonHome = false;
  double _stickPosX = 30.0;
  double _stickPosY = 30.0;
  bool _led1 = false;
  bool _led2 = false;
  bool _led3 = false;
  bool _led4 = false;

  @override
  void dispose() {
    if(_joyCon != null){
      _joyCon!.close();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Center(
        child: Column(
          children: [
            _buildOpenClose(),
            _buildLEDArray(),
            const SizedBox(height: 20.0,),
            SizedBox(
              width: 120.0,
              child: _buildJoyConButton(),
            ),
          ],
        ),
      ),
    );
  }

  void _onInputReport(Uint8List data) {
    // var dataList = Uint8List.fromList(data.buffer.asUint8List());
    switch(data[0]){
      case 0x30:
        var button = parse.parseCompleteButtonStatus(data);
        // TODO: This should use proper calibration data and not a magic number (2140, 1785).
        var stick = parse.parseAnalogStickRight(data, 2140, 1785);
        setState(() {
          _buttonY = button.buttonY;
          _buttonX = button.buttonX;
          _buttonB = button.buttonB;
          _buttonA = button.buttonA;
          _buttonSR = button.buttonSR;
          _buttonSL = button.buttonSL;
          _buttonR = button.buttonR;
          _buttonZR = button.buttonZR;
          _buttonPlus = button.buttonPlus;
          _buttonRightStick = button.buttonRightStick;
          _buttonHome = button.buttonHome;
          _stickPosX = stick.posX * 30.0 + 30.0;
          _stickPosY = stick.posY * 30.0 + 30.0;
        });
        break;
      default:
        break;
    }
  }

  Widget _buildOpenClose() {
    return ElevatedButton(
      child: Text(_isConnect?'Disconnect':'Connect'),
      onPressed: () async {
        // Prompt user to select a Joy-Con device.
        try {
          if(_isConnect){
            _joyCon?.close();
            setState(() {
              _joyCon = null;
              _isConnect = false;
            });
            return;
          }
          List<HidDevice> list = await hid.requestDevice(
              RequestOptions(
                filters: [
                  joyConRightDeviceIds
                ],
              )
          );
          if (list.isEmpty) {
            return;
          }
          var joyCon = JoyCon(
            device: list[0],
            onInputReport: _onInputReport,
          );
          await joyCon.open();
          await joyCon.enableUSBHIDJoystickReport();
          await joyCon.enableStandardFullMode();
          await joyCon.enableIMUMode();
          await joyCon.setLEDState(_led1, _led2, _led3, _led4);
          setState(() {
            _joyCon = joyCon;
            _isConnect = true;
          });
        } catch (error) {
          setState(() {
            _joyCon = null;
            _isConnect = false;
          });
          MotionToast.error(description: Text(error.toString()));
        }
      },
    );
  }

  Widget _buildLEDArray(){
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 20.0,
          height: 20.0,
          child: IconButton(
              iconSize: 12,
              onPressed:  () async{
                if(_joyCon != null) {
                  _joyCon!.setLEDState(!_led1, _led2, _led3, _led4);
                }
                setState(() {
                  _led1 = !_led1;
                });
              },
              icon: Icon(
                Icons.square,
                color: _led1 ? Colors.greenAccent : Colors.black,
              )
          ),
        ),
        SizedBox(
          width: 20.0,
          height: 20.0,
          child: IconButton(
              iconSize: 12,
              onPressed:  () async{
                if(_joyCon != null) {
                  _joyCon!.setLEDState(_led1, !_led2, _led3, _led4);
                }
                setState(() {
                  _led2 = !_led2;
                });
              },
              icon: Icon(
                Icons.square,
                color: _led2 ? Colors.greenAccent : Colors.black,
              )
          ),
        ),
        SizedBox(
          width: 20.0,
          height: 20.0,
          child: IconButton(
              iconSize: 12,
              onPressed:  () async{
                if(_joyCon != null) {
                  _joyCon!.setLEDState(_led1, _led2, !_led3, _led4);
                }
                setState(() {
                  _led3 = !_led3;
                });
              },
              icon: Icon(
                Icons.square,
                color: _led3 ? Colors.greenAccent : Colors.black,
              )
          ),
        ),
        SizedBox(
          width: 20.0,
          height: 20.0,
          child: IconButton(
              iconSize: 12,
              onPressed:  () async{
                if(_joyCon != null) {
                  _joyCon!.setLEDState(_led1, _led2, _led3, !_led4);
                }
                setState(() {
                  _led4 = !_led4;
                });
              },
              icon: Icon(
                Icons.square,
                color: _led4 ? Colors.greenAccent : Colors.black,
              )
          ),
        ),
      ],
    );
  }

  Widget _buildJoyConButton() {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 20.0,
              height: 20.0,
              color: _buttonPlus ? Colors.grey.withOpacity(.6) : Colors.grey,
              child: Text('➕',
                style: TextStyle( color: _buttonPlus ? Colors.red : Colors.black,),),
            ),
            const SizedBox(width: 5,),
            Container(
              width: 40.0,
              height: 20.0,
              color: _buttonR ? Colors.grey.withOpacity(.6) : Colors.grey,
              child: Text('R',
                style: TextStyle( color: _buttonR ? Colors.red : Colors.black,),),
            ),
            const SizedBox(width: 5,),
            Container(
              width: 40.0,
              height: 20.0,
              color: _buttonZR ? Colors.grey.withOpacity(.6) : Colors.grey,
              child: Text('ZR',
                style: TextStyle( color: _buttonZR? Colors.red : Colors.black,),),
            ),
          ],
        ),
        const SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            RotatedBox(
              quarterTurns: 1,
              child: Container(
                color: _buttonSR ? Colors.grey.withOpacity(.6) : Colors.grey,
                height: 20,
                width: 20,
                child: Text('SR',
                  style: TextStyle( color: _buttonSR ? Colors.red : Colors.black,),),
              ),),
            const SizedBox(width: 5.0,),
            SizedBox(
              width: 80.0,
              height: 80.0,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Container(
                        color: _buttonX ? Colors.grey.withOpacity(.6) : Colors.grey,
                        height: 20,
                        width: 20,
                        child: Text('X',
                          style: TextStyle( color: _buttonX ? Colors.red : Colors.black,),),
                      ),
                      const Expanded(child: SizedBox())
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Container(
                        color: _buttonY ? Colors.grey.withOpacity(.6) : Colors.grey,
                        height: 20,
                        width: 20,
                        child: Text('Y',
                          style: TextStyle( color: _buttonY ? Colors.red : Colors.black,),),
                      ),
                      const SizedBox(width: 20,),
                      Container(
                        color: _buttonA ? Colors.grey.withOpacity(.6) : Colors.grey,
                        height: 20,
                        width: 20,
                        child: Text('A',
                          style: TextStyle( color: _buttonA ? Colors.red : Colors.black,),),
                      ),
                      const Expanded(child: SizedBox())
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Container(
                        color: _buttonB ? Colors.grey.withOpacity(.6) : Colors.grey,
                        height: 20,
                        width: 20,
                        child: Text('B',
                          style: TextStyle( color: _buttonB ? Colors.red : Colors.black,),),
                      ),
                      const Expanded(child: SizedBox())
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            RotatedBox(
              quarterTurns: 1,
              child: Container(
                color: _buttonSL ? Colors.grey.withOpacity(.6) : Colors.grey,
                height: 20,
                width: 20,
                child: Text('SL',
                  style: TextStyle( color: _buttonSL ? Colors.red : Colors.black,),),
              ),),
            const SizedBox(width: 5.0,),
            Stack(
                children: [
                  Container(
                    width: 80.0,
                    height: 80.0,
                    // margin: EdgeInsets.all(100.0),
                    decoration: BoxDecoration(
                        color: _buttonRightStick ? Colors.grey.withOpacity(.6) : Colors.grey,
                        shape: BoxShape.circle
                    ),
                  ),
                  Positioned(
                      left: _stickPosX,
                      top: _stickPosY,
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                            color: _buttonRightStick ? Colors.red : Colors.black,
                            shape: BoxShape.circle
                        ),
                      )
                  ),
                ]
            ),
          ],
        ),
        const SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              color: _buttonHome ? Colors.grey.withOpacity(.6) : Colors.grey,
              height: 24,
              width: 24,
              child: Icon(
                Icons.home_filled,
                color: _buttonHome ? Colors.red : Colors.black,
              )
            ),
            const SizedBox(width: 80,),
            const SizedBox(width: 5.0,),
          ],
        ),
        const SizedBox(height: 40,)
      ],
    );
  }
}

