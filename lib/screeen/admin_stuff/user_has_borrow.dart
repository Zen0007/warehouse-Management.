import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:werehouse_inventory/page/first_screen.dart';
import 'package:werehouse_inventory/screeen/user_stuff/category_user.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class UserHasBorrows extends StatefulWidget {
  const UserHasBorrows({super.key});

  @override
  State<UserHasBorrows> createState() => _UserHasBorrowsState();
}

class _UserHasBorrowsState extends State<UserHasBorrows> {
  void selectCategory(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScreenCategoryUser(
          title: title,
        ),
      ),
    );
  }

  void sumbit(BuildContext context, WebsocketHelper wsHelper) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final getToken = prefs.getString('hasBorrow');
      wsHelper.sendMessage(
        {
          "endpoint": "waitPermision",
          "data": {
            "name": getToken ?? "",
          }
        },
      );

      await for (var data in wsHelper.streamController.stream) {
        if (data['endpoint'] == 'WAITPERMISION') {
          if (data.containsKey("warning")) {
            final String warning = data['warning'];
            if (!context.mounted) return;
            messages(
              context,
              warning,
              Theme.of(context).colorScheme.onPrimary,
              Theme.of(context).colorScheme.secondary,
            );

            debugPrint("$warning waring");
            return;
          } else if (data.containsKey('message')) {
            if (!context.mounted) return;
            final message = data['message'];
            messages(
              context,
              message,
              Theme.of(context).colorScheme.onPrimary,
              Theme.of(context).colorScheme.secondary,
            );
          }
        }
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<dynamic> messages(BuildContext context, String message, Color color,
      Color backgroundColor) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor: backgroundColor,
        title: Text(
          'MESSAGE',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: backgroundColor,
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Yes",
              style: TextStyle(
                color: color,
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          ListView(
            children: [
              Consumer<WebsocketHelper>(
                builder: (contex, wsHelper, child) {
                  return StreamBuilder(
                    stream: wsHelper.userHasBorrow(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data != null) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              int count;

                              debugPrint("${constraints.maxWidth} WIdth");

                              if (constraints.maxWidth < 480) {
                                count = 2;
                              } else if (constraints.maxWidth < 700) {
                                count = 3;
                              } else if (constraints.maxWidth < 900) {
                                count = 4;
                              } else if (constraints.maxWidth < 1000) {
                                count = 5;
                              } else {
                                count = 6;
                              }

                              double sizeImage = constraints.maxWidth / count;

                              return Column(
                                children: [
                                  SizedBox(
                                    height: constraints.maxWidth * 0.05,
                                  ),
                                  Center(
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        boxShadow: const [
                                          BoxShadow(
                                            blurRadius: 10,
                                            offset: Offset(0, 10),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child: Image.memory(
                                          snapshot.data!.imageUser,
                                          height: sizeImage * 0.76,
                                          width: sizeImage * 0.86,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: constraints.maxWidth * 0.02,
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: constraints.maxWidth * 0.01),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            nameTitle(constraints, context,
                                                snapshot.data!.nameUser!),
                                            nameTitle(constraints, context,
                                                snapshot.data!.classUser!),
                                            nameTitle(constraints, context,
                                                snapshot.data!.nisn!),
                                            nameTitle(constraints, context,
                                                snapshot.data!.status!),
                                            nameTitle(constraints, context,
                                                snapshot.data!.nameTeacher!),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 20, bottom: 10),
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5.5),
                                    ),
                                    child: Text(
                                      "list data borrow use",
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 25),
                                    ),
                                  ),
                                  for (var i = 0;
                                      i < snapshot.data!.item.length;
                                      i++)
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: constraints.maxWidth * 0.02,
                                        bottom: constraints.maxWidth * 0.02,
                                        left: constraints.maxWidth * 0.025,
                                        right: constraints.maxWidth * 0.025,
                                      ),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          borderRadius:
                                              BorderRadius.circular(5.5)),
                                      height: constraints.maxWidth * 0.12,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: constraints.maxWidth * 0.02,
                                          ),
                                          Container(
                                            height: constraints.maxWidth * 0.08,
                                            width: constraints.maxWidth * 0.08,
                                            decoration: BoxDecoration(
                                              color: Colors.amber,
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                            ),
                                            child: Center(
                                              child: Text(
                                                snapshot.data!.item[i].index,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSecondary,
                                                  fontSize:
                                                      constraints.maxWidth *
                                                          0.035,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: constraints.maxWidth * 0.03,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                snapshot.data!.item[i].nameItem,
                                                style: TextStyle(
                                                  fontSize:
                                                      constraints.maxWidth *
                                                          0.03,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    constraints.maxWidth * 0.01,
                                              ),
                                              Text(
                                                snapshot.data!.item[i].category,
                                                style: TextStyle(
                                                  fontSize:
                                                      constraints.maxWidth *
                                                          0.02,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: constraints.maxWidth * 0.077,
                                          ),
                                          Text(
                                            snapshot.data!.item[i].label
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize:
                                                  constraints.maxWidth * 0.035,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            },
                          );
                        } else {
                          // if not have data return to firstscreen
                          return FirstScreen();
                        }
                      } else if (!snapshot.hasData) {
                        return Center(
                          child: Text(
                            "${snapshot.data}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        );
                      } else {
                        return Center(
                          child: Text(
                            'is not found ${snapshot.error}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: Consumer<WebsocketHelper>(
              builder: (context, wsHelper, child) {
                return MaterialButton(
                  color: Colors.blue,
                  onPressed: () {
                    wsHelper.testDeleteUser();
                  },
                  child: Text("kembalikan"),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Container nameTitle(
    BoxConstraints constraints,
    BuildContext context,
    String title,
  ) {
    return Container(
      margin: EdgeInsets.only(
          left: constraints.maxWidth * 0.025,
          bottom: constraints.maxWidth * 0.02),
      padding: EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(5.5)),
      height: constraints.maxWidth * 0.065,
      width: constraints.maxWidth * 0.6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: constraints.maxWidth * 0.03,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
