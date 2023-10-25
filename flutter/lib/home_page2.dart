import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

import 'models/platform_model.dart';
import 'models/server_model.dart';

class HomePage2 extends StatefulWidget {
  HomePage2();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage2> {

  bool _isStart = false;

  final _toAndroidChannel = const MethodChannel('mChannel');

  final List<Client> _clients = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    // 初始化配置
    Map<String, dynamic> oldOptions = jsonDecode(await bind.mainGetOptions());
    print('Sting oldOptions:$oldOptions');
    //String id0 = oldOptions['custom-rendezvous-server'] ?? "";
    //String relay0 = oldOptions['relay-server'] ?? "";
    String api0 = oldOptions['api-server'] ?? "";
    if (api0.isEmpty) {
      bind.mainSetOption(key: "relay-server", value: '34.83.47.116:21116');
    }
    String key0 = oldOptions['key'] ?? "";
    if (key0.isEmpty) {
      bind.mainSetOption(key: "key", value: '67Wh8GdegxRvaai2KcCgOj8DpziuOGeB8IbRanhkVFE=');
    }

    // 启动服务
    await startService();

  }


  /// Start the screen sharing service.
  Future<Null> startService() async {
    _isStart = true;
    await _toAndroidChannel.invokeMethod("init_service");
    await bind.mainStartService();
    final id = await bind.mainGetMyId();
    final pw = await bind.mainGetPermanentPassword();
    print('Sting id:$id pw:$pw');
    updateClientState();
    Wakelock.enable();
  }

  // force
  updateClientState([String? json]) async {
    var res = await bind.cmGetClientsState();
    try {
      final List clientsJson = jsonDecode(res);
      _clients.clear();
      for (var clientJson in clientsJson) {
        final client = Client.fromJson(clientJson);
        _clients.add(client);
      }
    } catch (e) {
      debugPrint("Failed to updateClientState:$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("RustDesk"),
        ),
        body: Container(),
      ),
    );
  }
}
