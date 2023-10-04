// ignore_for_file: avoid_print, avoid_web_libraries_in_flutter

import 'package:flutter/material.dart';
import 'package:web_hid/web_hid.dart';
import 'package:web_hid_example/joy_con_page.dart';

import 'ledger_nano_s_page.dart';
import 'mac_key_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('web_hid example'),
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
            const SizedBox(height: 5.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text('hid.subscribeConnect'),
                  onPressed: () {
                    hid.subscribeConnect((device){
                      print('HID connected: ${device.getProperty('productName')}');
                    });
                    print('hid.subscribeConnect success');
                  },
                ),
                const SizedBox(width: 5.0,),
                ElevatedButton(
                  child: const Text('hid.unsubscribeConnect'),
                  onPressed: () {
                    hid.unsubscribeConnect((){
                      print('hid.unsubscribeConnect finish');
                    });
                    print('hid.unsubscribeConnect success');
                  },
                ),
              ],
            ),
            const SizedBox(height: 5.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text('hid.subscribeDisconnect'),
                  onPressed: () {
                    hid.subscribeDisconnect((device){
                      print('HID disconnected: ${device.getProperty('productName')}');
                    });
                    print('hid.subscribeDisconnect success');
                  },
                ),
                const SizedBox(width: 5.0,),
                ElevatedButton(
                  child: const Text('hid.unsubscribeDisconnect'),
                  onPressed: () {
                    hid.unsubscribeDisconnect((){
                      print('hid.unsubscribeDisconnect finish');
                    });
                    print('hid.unsubscribeDisconnect success');
                  },
                ),
              ],
            ),
            const SizedBox(height: 5.0,),
            ElevatedButton(
              child: const Text('Request Device'),
              onPressed: () async {

                List<HidDevice> list = await hid.requestDevice(
                    RequestOptions(
                      filters: [
                      ],
                    )
                );
                if (list.isEmpty) {
                  return;
                }
                var device = list[0];
                if(!device.opened) {
                  device.open();
                }
              },
            ),
            const SizedBox(height: 5.0,),
            ElevatedButton(
              child: const Text('Mac Key Conf'),
              onPressed: () {
                var route = MaterialPageRoute(builder: (context) {
                  return const MacKeyPage();
                });
                Navigator.of(context).push(route);
              },
            ),
            const SizedBox(height: 5.0,),
            ElevatedButton(
              child: const Text('Ledger Nano S'),
              onPressed: () {
                var route = MaterialPageRoute(builder: (context) {
                  return const LedgerNanoSPage();
                });
                Navigator.of(context).push(route);
              },
            ),
            const SizedBox(height: 5.0,),
            ElevatedButton(
              child: const Text('Joy Con'),
              onPressed: () {
                var route = MaterialPageRoute(builder: (context) {
                  return const JoyConPage();
                });
                Navigator.of(context).push(route);
              },
            ),
          ],
        ),
      ),
    );
  }
}
