import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/page/first_screen.dart';
import 'package:werehouse_inventory/screeen/user_stuff/user_has_borrow.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class MiddlePage extends StatefulWidget {
  const MiddlePage({super.key});

  @override
  State<MiddlePage> createState() => _MiddlePageState();
}

class _MiddlePageState extends State<MiddlePage> {
  @override
  Widget build(BuildContext context) {
    final secondaryWs = Provider.of<WebsocketHelper>(context, listen: true);
    secondaryWs.checkUserHasBorrow();
    return Scaffold(
      body: StreamBuilder(
        stream: secondaryWs.checkUserHasBorrows.stream,
        builder: (context, snapshot) {
          print("${snapshot.hasData} data middle");
          if (snapshot.hasData) {
            return UserHasBorrows();
          }
          return FirstScreen();
        },
      ),
    );
  }
}
