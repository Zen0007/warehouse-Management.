import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/page/app.dart';
import 'package:werehouse_inventory/shered_data_to_root/auth_service.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<WebsocketHelper>(
          create: (_) => WebsocketHelper(
            WebSocketChannel.connect(Uri.parse('ws://ws-server:8080/ws')),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthService(
            context.read<WebsocketHelper>(),
          ),
        )
      ],
      child: App(),
    ),
  );
}
