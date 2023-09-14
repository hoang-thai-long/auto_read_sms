import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:readsms/readsms.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _plugin = Readsms();
  String sms = 'no sms received';
  String sender = 'no sms received';
  String time = 'no sms received';

  @override
  void initState() {
    super.initState();
    getPermission().then((value) {
      if (value) {
        _plugin.read();
        _plugin.smsStream.listen((event) {
          createPaymentSMS(event.body, event.sender, event.timeReceived);
          setState(() {
            sms = event.body;
            sender = event.sender;
            time = event.timeReceived.toString();
          });
        });
      }
    });
  }

  Future<bool> getPermission() async {
    if (await Permission.sms.status == PermissionStatus.granted) {
      return true;
    } else {
      if (await Permission.sms.request() == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<http.Response> createPaymentSMS(
      String body, String sender, DateTime receive) {
    return http.post(
      Uri.parse('https://payment.eduso.vn/sms'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'SMS_APP': 'longht-sender'
      },
      body: jsonEncode(<String, String>{
        'sms': body,
        'sender': sender,
        'time': receive.toString()
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _plugin.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('new sms received: $sms'),
              Text('new sms Sender: $sender'),
              Text('new sms time: $time'),
            ],
          ),
        ),
      ),
    );
  }
}
