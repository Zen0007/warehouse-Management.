import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/page/home_page.dart';
import 'package:werehouse_inventory/page/middle_screen.dart';
import 'package:werehouse_inventory/theme_data/theme_page.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeColorPage.lightTheme,
      darkTheme: ThemeColorPage.darkTheme,
      home: Consumer<WebsocketHelper>(
        builder: (context, wsHelper, child) {
          /*
          check token user in local storage
          */
          return StreamBuilder(
            stream: wsHelper.verifikasi(),
            builder: (context, snapshot) {
              print('${snapshot.data} status');
              /*
               check if token user is valide else is token invalide and nothing return
              */
              if (snapshot.hasData) {
                return HomePage();
              } else {
                return const MiddleScreen();
              }
            },
          );
        },
      ),
    );
  }
}
