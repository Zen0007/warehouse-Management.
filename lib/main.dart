import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/page/app.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<WebsocketHelper>(create: (_) => WebsocketHelper()),
    ],
    child: App(),
  ));
}
