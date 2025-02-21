import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:werehouse_inventory/configuration/add_data/controler_service_add.dart';
import 'package:werehouse_inventory/configuration/delete/controler_service_deleted.dart';
import 'package:werehouse_inventory/page/first_screen.dart';
import 'package:werehouse_inventory/screeen/admin_stuff/borrow.dart';
import 'package:werehouse_inventory/screeen/admin_stuff/grantend_user.dart';
import 'package:werehouse_inventory/screeen/user_stuff/grid_for_key.dart';
import 'package:werehouse_inventory/screeen/admin_stuff/category_admin.dart';
import 'package:werehouse_inventory/screeen/admin_stuff/pending_user.dart';
import 'package:werehouse_inventory/shered_data_to_root/auth_service.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class HomePage extends StatelessWidget {
  HomePage({
    super.key,
  });

  final GlobalKey<ScaffoldState> drawer = GlobalKey<ScaffoldState>();

  void selectCategory(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryAdmin(
          title: title,
        ),
      ),
    );
  }

  Future<String?> nameAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString("adminName");

    return name;
  }

  Future<dynamic> detailAdmin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString("adminName");

    if (!context.mounted) {
      return;
    }
    return showDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: 50,
              right: 10,
              child: Container(
                width: 150,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.only(
                  left: 5,
                  right: 5,
                ),
                child: Center(
                  child: Text(
                    "Name : $name",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Future<dynamic> messages(BuildContext context, String response) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor: Theme.of(context).colorScheme.error,
        title: Text(
          "MESSAGE",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          response,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Yes",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondaryWs = Provider.of<AuthService>(context, listen: true);
    secondaryWs.removeTokenIfExp();
    secondaryWs.chekVerifikasi();

    final size = MediaQuery.of(context).size;

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
          IconButton(
            onPressed: () => detailAdmin(context),
            icon: Icon(
              Icons.person,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      drawer: Drawer(
        child: Stack(
          children: [
            Consumer<WebsocketHelper>(
              builder: (contex, wsHelper, child) {
                return ListView(
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
                    ExpansionTile(
                      title: Text(
                        "Category",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      leading: Icon(
                        color: Theme.of(context).colorScheme.onPrimary,
                        Icons.adjust_sharp,
                      ),
                      childrenPadding: const EdgeInsets.only(
                        left: 60,
                        bottom: 10,
                      ),
                      onExpansionChanged: (value) {
                        if (value) {
                          // send request to ws
                          wsHelper.getAllKeyCategoryOnce();
                        }
                      },
                      children: [
                        StreamBuilder(
                          stream: wsHelper.streamKeyResult.stream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 5, right: 15),
                                  child: LinearProgressIndicator(),
                                ),
                              );
                            }
                            if (snapshot.hasData) {
                              // process key to list
                              final key = wsHelper.processKey(snapshot.data!);

                              if (key.isEmpty) {
                                return Center(
                                  child: ListTile(
                                    title: Text(
                                      "Daftar category kosong ",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Column(
                                children: [
                                  for (final data in key)
                                    ListCategory(
                                      category: data.key,
                                      onSelectCategory: () {
                                        // get all data for admin once
                                        wsHelper.getDataAllCollectionOnce();
                                        selectCategory(
                                          context,
                                          data.key,
                                        );

                                        print("is Press");
                                      },
                                    ),
                                ],
                              );
                            } else {
                              messages(context,
                                  '${snapshot.error}'); // pop up message error
                              return ListTile(
                                title: Text(
                                  "error",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    ListTile(
                      leading: Icon(
                        color: Theme.of(context).colorScheme.onPrimary,
                        Icons.adjust_sharp,
                      ),
                      title: Text(
                        "item di pinjam",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BorrowUserPage(),
                          ),
                        );

                        wsHelper.getDataBorrowOnce(); // send request to ws
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        color: Theme.of(context).colorScheme.onPrimary,
                        Icons.adjust_sharp,
                      ),
                      title: Text(
                        "menungu ijin",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PendingUser(),
                          ),
                        );
                        wsHelper.getDataPendingOnce(); // send request to ws
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        color: Theme.of(context).colorScheme.onPrimary,
                        Icons.adjust_sharp,
                      ),
                      title: Text(
                        "item kembali",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const GrantendUser()),
                        );
                        wsHelper.getDataGrantedOnce();
                      },
                    ),
                    ExpansionTile(
                      title: Text(
                        "service",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      leading: Icon(
                        color: Theme.of(context).colorScheme.onPrimary,
                        Icons.adjust_sharp,
                      ),
                      childrenPadding: const EdgeInsets.only(
                        left: 60,
                        bottom: 10,
                      ),
                      children: [
                        ListTile(
                          leading: Icon(
                            color: Theme.of(context).colorScheme.onPrimary,
                            Icons.circle_outlined,
                          ),
                          title: Text(
                            "Controller insert ",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          onTap: () {
                            wsHelper.getAllKeyCategoryOnce();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ControllerService(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            color: Theme.of(context).colorScheme.onPrimary,
                            Icons.circle_outlined,
                          ),
                          title: Text(
                            "Controller delete",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ControllerServiceDeleted(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 10,
                            top: 15,
                            bottom: 15,
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FirstScreen(),
                                ),
                              );
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.remove("token");
                              debugPrint('${prefs.getString('token')}  token');
                            },
                            child: Text(
                              'logout',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            // Positioned(
            //   bottom: 10,
            //   right: 10,
            //   child:
            // ),
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
            debugPrint("${constraints.maxWidth}");
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
            debugPrint("${constraints.maxWidth}");
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
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              flex: 2,
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
          ],
        ),
        Positioned(
          left: size.width * 0.45,
          top: constraints.maxHeight * 0.1,
          child: Container(
            width: size.width * 0.5,
            height: constraints.maxWidth * 0.35,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        Positioned(
          left: constraints.maxWidth * 0.05,
          top: constraints.maxHeight * 0.25,
          child: Container(
            width: size.width * 0.35,
            height: constraints.maxWidth * 0.15,
            color: Theme.of(context).colorScheme.secondary,
          ),
        )
      ],
    );
  }
}
