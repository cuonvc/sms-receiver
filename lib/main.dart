import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readsms/readsms.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // useMaterial3: false,
      ),
      home: const MyHomePage(title: 'Flutter SMS Receiver'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _plugin = Readsms();
  String content = '';
  String sender = '';
  String time = '';
  String pendingText = 'Đang đợi ting ting từ người ấy...';
  String imagePath = 'image/pepe.png';

  @override
  void initState() {
    super.initState();
    getPermission().then((value) {
      if (value) {
        _plugin.read();
        _plugin.smsStream.listen((event) async {
          setState(() {
            content = 'Nội dung: ' + event.body;
            sender = 'Người gửi: ' + event.sender;
            time = 'Thời gian: ' + event.timeReceived.toString();
            pendingText = 'Có tin nhắn mới...';
            imagePath = 'image/3nRK.gif';
          });

          //post message data to the HAU-Ecommerce server
          final uri = Uri.parse("https://viper-chief-secondly.ngrok-free.app/api/order/wallet/deposit/submit");
          Map<String, dynamic> request = {
            'sender': event.sender,
            'content': event.body,
            'time': event.timeReceived.toString()
          };

          final response = await http.post(
              uri,
              headers: {"Content-Type": "application/json"},
              body: json.encode(request)
          );
          print('Response sms - ' + response.statusCode.toString());
        });
      }
    });
  }


  @override
  void dispose() {
    super.dispose();
    _plugin.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Center(
          child: Text(
            widget.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage(imagePath),
              width: 150,
              height: 200,
            ),
            Padding(padding: EdgeInsets.only(top: 20)),
            Text(
              pendingText,
              style: TextStyle(
                fontSize: 18
              ),
            ),
            Text(sender, style: TextStyle(fontSize: 16),),
            Text(content, style: TextStyle(fontSize: 16),),
            Text(time, style: TextStyle(fontSize: 16),)
          ],
        ),
      ),
    );
  }
}
