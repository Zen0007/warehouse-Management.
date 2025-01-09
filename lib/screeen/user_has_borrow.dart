import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:werehouse_inventory/card/card_borrow.dart';
import 'package:werehouse_inventory/screeen/user%20staff/category_user.dart';
import 'package:werehouse_inventory/screeen/user%20staff/list_staff_user.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class UserHasBorrow extends StatelessWidget {
  const UserHasBorrow({super.key});

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
            "name": getToken,
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
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            "List Items",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ListStaffUser(),
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              icon: Icon(
                Icons.bookmark,
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Consumer<WebsocketHelper>(
          builder: (contex, wsHelper, child) {
            return StreamBuilder(
              stream: wsHelper.checkUserHasBorrow(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                } else if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        int count;
                        double mainAxisExtent;
                        debugPrint("${constraints.maxWidth} WITHT");

                        if (constraints.maxWidth < 480) {
                          count = 2;
                          mainAxisExtent = constraints.maxWidth * 0.4;
                        } else if (constraints.maxWidth < 700) {
                          count = 3;
                          mainAxisExtent = constraints.maxWidth * 0.25;
                        } else if (constraints.maxWidth < 900) {
                          count = 4;
                          mainAxisExtent = constraints.maxWidth * 0.2;
                        } else if (constraints.maxWidth < 1000) {
                          count = 5;
                          mainAxisExtent = constraints.maxWidth * 0.17;
                        } else {
                          count = 6;
                          mainAxisExtent = constraints.maxWidth * 0.15;
                        }

                        double sizeImage = constraints.maxWidth / count;

                        return GridView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: count,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 8,
                            mainAxisExtent: mainAxisExtent,
                          ),
                          itemBuilder: (context, index) {
                            return CardBorrow(
                              data: snapshot.data![index],
                              imageSize: sizeImage,
                            );
                          },
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text(
                        'not have item',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 30,
                        ),
                      ),
                    );
                  }
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
        floatingActionButton: Consumer<WebsocketHelper>(
          builder: (contex, wsHelper, child) {
            return TextButton(
              onPressed: () {
                sumbit(context, wsHelper);
              },
              child: Text(
                'Kembalikan',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            );
          },
        ));
  }
}
