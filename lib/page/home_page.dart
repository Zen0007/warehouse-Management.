import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:werehouse_inventory/configuration/add_data/screen_service.dart';
import 'package:werehouse_inventory/configuration/delete/controler_service.dart';
import 'package:werehouse_inventory/page/middle_screen.dart';
import 'package:werehouse_inventory/screeen/borrow.dart';
import 'package:werehouse_inventory/screeen/user_stuff/list_key_category.dart';
import 'package:werehouse_inventory/screeen/category_admin.dart';
import 'package:werehouse_inventory/screeen/pending_user.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class HomePage extends StatelessWidget {
  final String? name;
  HomePage({super.key, this.name});

  final GlobalKey<ScaffoldState> drawer = GlobalKey<ScaffoldState>();

  void selectCategory(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScreenCategoryAdmin(
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {},
            icon: Icon(
              color: Theme.of(context).colorScheme.onPrimary,
              Icons.person,
            ),
          ),
          Text(
            "name admin",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
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
                          wsHelper.getAllKeyCategory();
                        }
                      },
                      children: [
                        FutureBuilder(
                          future: wsHelper.keyCategory(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator.adaptive(),
                              );
                            } else if (snapshot.hasData) {
                              return Column(
                                children: [
                                  if (snapshot.data!.isNotEmpty) ...[
                                    for (final data in snapshot.data!)
                                      ListCategory(
                                        category: data.key,
                                        onSelectCategory: () {
                                          selectCategory(
                                            context,
                                            data.key,
                                          );

                                          // get all data for admin
                                          wsHelper.getDataAllCollection();
                                        },
                                      ),
                                  ] else
                                    Text('category key kosong'),
                                ],
                              );
                            } else {
                              return ListTile(
                                title: Text(
                                  "${snapshot.error}",
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

                        wsHelper.getDataBorrow(); // send request to ws
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
                        wsHelper.getDataPending();
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
                      // onTap: () => Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const BorrowUser()),
                      // ),
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
                            Icons.adjust_sharp,
                          ),
                          title: Text(
                            "add",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ControllerService(),
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            color: Theme.of(context).colorScheme.onPrimary,
                            Icons.adjust_sharp,
                          ),
                          title: Text(
                            "delete",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ControllerServiceDelete()),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MiddleScreen(),
                    ),
                  );
                  final prefs = await SharedPreferences.getInstance();
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
