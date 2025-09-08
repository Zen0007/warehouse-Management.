import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/page/first_screen.dart';
import 'package:werehouse_inventory/screeen/user_stuff/user_has_borrow.dart';
import 'package:werehouse_inventory/shered_data_to_root/auth_service.dart';

class MiddlePage extends StatefulWidget {
  const MiddlePage({super.key});

  @override
  State<MiddlePage> createState() => _MiddlePageState();
}

class _MiddlePageState extends State<MiddlePage> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: true);

    return Scaffold(
      body: StreamBuilder(
        stream: authService.userHasBorrow(),
        builder: (context, snapshot) {
          print("${snapshot.hasData} data middle");
          if (snapshot.data != null) {
            return UserHasBorrows();
          }

          return FirstScreen();
        },
      ),
    );
  }
}
