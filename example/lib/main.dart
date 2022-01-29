// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:web_hid/web_hid.dart';

import 'ledger_nano_s_page.dart';
import 'logic_keyboard_page.dart';
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
            ElevatedButton(
              child: const Text('Mac Key Conf'),
              onPressed: () {
                var route = MaterialPageRoute(builder: (context) {
                  return const MacKeyPage();
                });
                Navigator.of(context).push(route);
              },
            ),
            ElevatedButton(
              child: const Text('Ledger Nano S'),
              onPressed: () {
                var route = MaterialPageRoute(builder: (context) {
                  return const LedgerNanoSPage();
                });
                Navigator.of(context).push(route);
              },
            ),
            ElevatedButton(
              child: const Text('Logic Keyboard Conf'),
              onPressed: () {
                var route = MaterialPageRoute(builder: (context) {
                  return const LogicKeyboardPage();
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
