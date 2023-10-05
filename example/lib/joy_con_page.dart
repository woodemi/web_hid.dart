
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_hid/web_hid.dart';

import 'joy_con_core.dart';

class JoyConPage extends StatefulWidget {
  const JoyConPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _JoyConPageState();
}
class _JoyConPageState extends State<JoyConPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joy Con'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: JoyCon(
                filter: RequestOptionsFilter(
                  vendorId: 0x057e, // Nintendo Co., Ltd
                  productId: 0x2006 // Joy-Con Left
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: JoyCon(
                filter: RequestOptionsFilter(
                  vendorId: 0x057e, // Nintendo Co., Ltd
                  productId: 0x2007 // Joy-Con Right
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// JoyCon
class JoyCon extends StatefulWidget{
  final RequestOptionsFilter filter;
  const JoyCon({super.key, required this.filter});

  @override
  State<StatefulWidget> createState() => _JoyConState();
}

class _JoyConState extends State<JoyCon>{
  JoyConCore? _joyCon;
  bool _isConnect = false;
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
      height: 120.0,
      child: Center(
        child: Column(
          children: [
            _buildOpenClose(),
            const SizedBox(height: 20.0,),
            _buildLEDArray(),
          ],
        ),
      ),
    );
  }

  void _onInputReport(Uint8List data) {
    print('onInputReport: ${data.map((e) => e.toRadixString(16).toUpperCase().padLeft(2, '0'))}');
  }

  void _refreshLED(){
    if(_joyCon != null){
      _joyCon!.setLEDState(_led1, _led2, _led3, _led4);
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
                widget.filter
              ],
            )
          );
          if (list.isEmpty) {
            return;
          }
          var joyCon = JoyConCore(
            device: list[0],
            onInputReport: _onInputReport,
          );

          await joyCon.open();
          setState(() {
            _joyCon = joyCon;
            _isConnect = true;
          });
          _refreshLED();
        } catch (error) {
          setState(() {
            _joyCon = null;
            _isConnect = false;
          });
          print(error);
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
          child: IconButton(
              onPressed: () {
                setState(() {
                  _led1 = !_led1;
                });
                _refreshLED();
              },
              icon: Icon(
                Icons.square,
                color: _led1 ? Colors.greenAccent : Colors.black,
              )
          ),
        ),
        SizedBox(
          child: IconButton(
              onPressed: () {
                setState(() {
                  _led2 = !_led2;
                });
                _refreshLED();
              },
              icon: Icon(
                Icons.square,
                color: _led2 ? Colors.greenAccent : Colors.black,
              )
          ),
        ),
        SizedBox(
          child: IconButton(
              onPressed: () {
                setState(() {
                  _led3 = !_led3;
                });
                _refreshLED();
              },
              icon: Icon(
                Icons.square,
                color: _led3 ? Colors.greenAccent : Colors.black,
              )
          ),
        ),
        SizedBox(
          child: IconButton(
              onPressed: () {
                setState(() {
                  _led4 = !_led4;
                });
                _refreshLED();
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
}
