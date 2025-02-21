import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/page/home_page.dart';
import 'package:werehouse_inventory/page/middle_page.dart';
import 'package:werehouse_inventory/shered_data_to_root/auth_service.dart';
import 'package:werehouse_inventory/theme_data/theme_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    final secondaryWs = Provider.of<AuthService>(context, listen: true);
    secondaryWs.removeTokenIfExp();
    secondaryWs.chekVerifikasi();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeColorPage.lightTheme,
      darkTheme: ThemeColorPage.darkTheme,
      home: StreamBuilder(
        stream: secondaryWs.verifikasiLogin(),
        builder: (context, snapshot) {
          // print('${snapshot.data} status');
          /*
               check if token user is valide else is token invalide and nothing return
              */
          print("has data ${snapshot.hasData}");
          if (snapshot.data == null) {
            return MiddlePage();
          }
          if (snapshot.data != null) {
            return HomePage();
          }
          return MiddlePage();
        },
      ),
    );
  }
}
