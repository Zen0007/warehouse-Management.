import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/page/first_screen.dart';
import 'package:werehouse_inventory/screeen/admin_stuff/user_has_borrow.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class MiddlePage extends StatefulWidget {
  const MiddlePage({super.key});

  @override
  State<MiddlePage> createState() => _MiddlePageState();
}

class _MiddlePageState extends State<MiddlePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WebsocketHelper>(
        builder: (context, wsHelper, child) {
          return StreamBuilder(
            stream: wsHelper.checkUserHasBorrow(),
            builder: (context, snapshot) {
              print("${snapshot.data} data middle");
              if (snapshot.hasData) {
                return const UserHasBorrows();
              } else {
                return const FirstScreen();
              }
            },
          );
        },
      ),
    );
  }
}
