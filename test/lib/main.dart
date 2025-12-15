import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

class MQTTWebPage extends StatefulWidget {
  @override
  _MQTTWebPageState createState() => _MQTTWebPageState();
}

class _MQTTWebPageState extends State<MQTTWebPage> {
  late MqttBrowserClient client;
  String message = "Waiting for messages...";

  @override
  void initState() {
    super.initState();
    connectMQTT();
  }

  Future<void> connectMQTT() async {
    client = MqttBrowserClient('ws://iicloud.tplinkdns.com:7036/mqtt', 'flutter_web_client');
    client.logging(on: true);
    client.keepAlivePeriod = 20;

    client.onConnected = () {
      print('Connected to broker');
      client.subscribe('your/topic', MqttQos.atMostOnce);
    };

    client.onDisconnected = () {
      print('Disconnected');
    };

    client.onSubscribed = (topic) {
      print('Subscribed to $topic');
    };

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      setState(() {
        message = pt;
      });
    });

    try {
      await client.connect();
    } catch (e) {
      print('Connection failed: $e');
      client.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MQTT WebSocket Demo')),
      body: Center(child: Text('Message: $message')),
    );
  }
}
