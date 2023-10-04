import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:web_hid/web_hid.dart';
import 'joy_con.dart';
import 'joy_con_parse.dart';

final joyConLeftDeviceIds = RequestOptionsFilter(
  vendorId: 0x057e,
  productId: 0x2006
);

class JoyConLeft extends StatefulWidget{
  const JoyConLeft({super.key});

  @override
  State<StatefulWidget> createState() => _JoyConLeftState();
}

class _JoyConLeftState extends State<JoyConLeft>{
  JoyCon? _joyCon;
  final parse = JoyConHIDParse();
  bool _isConnect = false;
  bool _buttonZL = false;
  bool _buttonL = false;
  bool _buttonSL = false;
  bool _buttonSR = false;
  bool _buttonDown = false;
  bool _buttonUp = false;
  bool _buttonRight = false;
  bool _buttonLeft = false;
  bool _buttonMinus = false;
  bool _buttonLeftStick = false;
  bool _buttonCapture = false;
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
    switch(data[0]){
      case 0x30:
        // parse.parseBatteryLevel(dataList);
        var button = parse.parseCompleteButtonStatus(data);
        // TODO: This should use proper calibration data and not a magic number (1985, 2220).
        var stick = parse.parseAnalogStickLeft(data, 1985, 2220);
        setState(() {
          _buttonDown = button.buttonDown;
          _buttonUp = button.buttonUp;
          _buttonRight = button.buttonRight;
          _buttonLeft = button.buttonLeft;
          _buttonSR = button.buttonSR;
          _buttonSL = button.buttonSL;
          _buttonL = button.buttonL;
          _buttonZL = button.buttonZL;
          _buttonMinus = button.buttonMinus;
          _buttonLeftStick = button.buttonLeftStick;
          _buttonCapture = button.buttonCapture;
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
                  joyConLeftDeviceIds
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
          if(mounted) {
            MotionToast.error(description: Text('Exception ${error.toString()}')).show(context);
          }
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
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          // mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40.0,
              height: 20.0,
              color: _buttonZL ? Colors.grey.withOpacity(.6) : Colors.grey,
              child: Text('ZL',
                style: TextStyle( color: _buttonZL ? Colors.red : Colors.black,),),
            ),
            const SizedBox(width: 5,),
            Container(
              width: 40.0,
              height: 20.0,
              color: _buttonL ? Colors.grey.withOpacity(.6) : Colors.grey,
              child: Text('L',
                style: TextStyle( color: _buttonL ? Colors.red : Colors.black,),),
            ),
            const SizedBox(width: 5,),
            Container(
              width: 20.0,
              height: 20.0,
              color: _buttonMinus ? Colors.grey.withOpacity(.6) : Colors.grey,
              child: Text('➖',
                style: TextStyle( color: _buttonMinus ? Colors.red : Colors.black,),),
            ),
          ],
        ),
        const SizedBox(height: 20,),
        Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 80.0,
                  height: 80.0,
                  // margin: EdgeInsets.all(100.0),
                  decoration: BoxDecoration(
                      color: _buttonLeftStick ? Colors.grey.withOpacity(.6) : Colors.grey,
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
                        color: _buttonLeftStick ? Colors.red : Colors.black,
                        shape: BoxShape.circle
                    ),
                  )
                ),
              ]
            ),
            const SizedBox(width: 5.0,),
            RotatedBox(
              quarterTurns: 1,
              child: Container(
                color: _buttonSL ? Colors.grey.withOpacity(.6) : Colors.grey,
                height: 20,
                width: 20,
                child: Text('SL',
                  style: TextStyle( color: _buttonSL ? Colors.red : Colors.black,),),
            ),)
          ],
        ),
        const SizedBox(height: 20,),
        Row(
          children: [
            SizedBox(
              width: 80.0,
              height: 80.0,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Container(
                        color: _buttonUp ? Colors.grey.withOpacity(.6) : Colors.grey,
                        height: 20,
                        width: 20,
                        child: Text('🔼',
                          style: TextStyle( color: _buttonUp ? Colors.red : Colors.black,),),
                      ),
                      const Expanded(child: SizedBox())
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Container(
                        color: _buttonLeft ? Colors.grey.withOpacity(.6) : Colors.grey,
                        height: 20,
                        width: 20,
                        child: Text('◀',
                          style: TextStyle( color: _buttonLeft ? Colors.red : Colors.black,),),
                      ),
                      const SizedBox(width: 20,),
                      Container(
                        color: _buttonRight ? Colors.grey.withOpacity(.6) : Colors.grey,
                        height: 20,
                        width: 20,
                        child: Text('▶',
                          style: TextStyle( color: _buttonRight ? Colors.red : Colors.black,),),
                      ),
                      const Expanded(child: SizedBox())
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Container(
                        color: _buttonDown ? Colors.grey.withOpacity(.6) : Colors.grey,
                        height: 20,
                        width: 20,
                        child: Text('🔽',
                          style: TextStyle( color: _buttonDown ? Colors.red : Colors.black,),),
                      ),
                      const Expanded(child: SizedBox())
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5.0,),
            RotatedBox(
              quarterTurns: 1,
              child: Container(
                color: _buttonSR ? Colors.grey.withOpacity(.6) : Colors.grey,
                height: 20,
                width: 20,
                child: Text('SR',
                  style: TextStyle( color: _buttonSR ? Colors.red : Colors.black,),),
              ),
            )
          ],
        ),
        const SizedBox(height: 20,),
        Row(
          children: [
            const SizedBox(width: 80,),
            const SizedBox(width: 5.0,),
            Container(
                color: _buttonCapture ? Colors.grey.withOpacity(.6) : Colors.grey,
                height: 24,
                width: 24,
                child: Icon(
                  Icons.circle,
                  color: _buttonCapture ? Colors.red : Colors.black,
                )
              ),
          ],
        ),
        const SizedBox(height: 40,)
      ],
    );
  }
}