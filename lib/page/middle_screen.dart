import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:werehouse_inventory/auth/login.dart';
import 'package:werehouse_inventory/fetch_socket.dart/verifikasi.dart';
import 'package:werehouse_inventory/page/home_page.dart';
import 'package:werehouse_inventory/screeen/user%20staff/list_category_user.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class MiddleScreen extends StatefulWidget {
  const MiddleScreen({super.key});

  @override
  State<MiddleScreen> createState() => _MiddleScreenState();
}

class _MiddleScreenState extends State<MiddleScreen> {
  final GlobalKey<ScaffoldState> drawer = GlobalKey<ScaffoldState>();

  // this before for cheak token user but not  can use provider
  void chekToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final getToken = prefs.getString('token');
      debugPrint("$getToken nameUser");

      if (getToken == null) return;

      if (getToken.isNotEmpty) {
        final stream = verifikasi(getToken);
        stream.listen(
          (message) {
            if (message["endpoint"] == "verikasi") {
              if (message.containsKey('message')) {
                debugPrint("middle");
                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
                return;
              } else if (message.containsKey("warning")) {
                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MiddleScreen(),
                  ),
                );
              }
            }
          },
        );
      }
    } catch (e, s) {
      debugPrint("$e");
      debugPrint('$s');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print(size);
    return Scaffold(
      key: drawer,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => drawer.currentState!.openDrawer(),
          icon: Icon(
            color: Theme.of(context).colorScheme.onPrimary,
            Icons.list,
          ),
        ),
        title: Text(
          "GUDANG TKJ",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Login(),
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            child: Text(
              "Login",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      drawer: Drawer(
        child: Stack(
          children: [
            ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  duration: const Duration(milliseconds: 5),
                  child: Text(
                    "Menu ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                /*
                    must add consumer so if user access availeble data so data automatic request to ws               
                */
                Consumer<WebsocketHelper>(
                  builder: (contex, wsHelper, child) {
                    return ListTile(
                      leading: Icon(
                        color: Theme.of(context).colorScheme.onPrimary,
                        Icons.adjust_sharp,
                      ),
                      title: Text(
                        "available item",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      onTap: () {
                        wsHelper.getAllKeyCategory();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ListCategoryUser(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 680) {
            return Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: constraints.maxWidth * 0.1,
                  top: constraints.maxWidth * 0.15,
                  right: constraints.maxWidth * 0.1,
                  child: Container(
                    width: constraints.maxWidth * 0.65,
                    height: constraints.maxHeight * 0.66,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                )
              ],
            );
          } else if (constraints.maxWidth < 800) {
            return Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: constraints.maxWidth * 0.25,
                  top: constraints.maxHeight * 0.1,
                  child: Container(
                    width: constraints.maxWidth * 0.65,
                    height: constraints.maxWidth * 0.55,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                )
              ],
            );
          } else if (constraints.maxWidth < 990) {
            return Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: constraints.maxWidth * 0.4,
                  top: constraints.maxHeight * 0.1,
                  child: Container(
                    width: constraints.maxWidth * 0.55,
                    height: constraints.maxWidth * 0.45,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Positioned(
                  left: constraints.maxWidth * 0.02,
                  top: constraints.maxHeight * 0.35,
                  child: Container(
                    width: size.width * 0.33,
                    height: constraints.maxWidth * 0.15,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            );
          } else {
            return dekstop(context, size, constraints);
          }
        },
      ),
    );
  }

  Stack dekstop(BuildContext context, Size size, BoxConstraints constraints) {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        Positioned(
          left: size.width * 0.45,
          top: constraints.maxHeight * 0.1,
          child: Container(
            width: size.width * 0.5,
            height: constraints.maxWidth * 0.35,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Positioned(
          left: constraints.maxWidth * 0.05,
          top: constraints.maxHeight * 0.25,
          child: Container(
            width: size.width * 0.35,
            height: constraints.maxWidth * 0.15,
            color: Theme.of(context).colorScheme.primary,
          ),
        )
      ],
    );
  }
}
