
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:web_hid/web_hid.dart';

import 'joy_con_left.dart';
import 'joy_con_right.dart';

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
        child: Column(
          children: [
            ElevatedButton(
              child: const Text('Check webHID available'),
              onPressed: () {
                bool canUse = canUseHid();
                if(canUse) {
                  MotionToast.success(
                      description:  const Text("webHID is available.")
                  ).show(context);
                } else {
                  MotionToast.error(
                      description:  const Text("webHID not available.")
                  ).show(context);
                }
              },
            ),
            _buildJoyCon()
          ],
        ),
      ),
    );
  }

  Widget _buildJoyCon() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: EdgeInsets.all(15.0),
          child: JoyConLeft(),
        ),
        Padding(
          padding: EdgeInsets.all(15.0),
          child: JoyConRight(),
        ),
      ],
    );
  }
}
