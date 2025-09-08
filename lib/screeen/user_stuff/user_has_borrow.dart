import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:werehouse_inventory/data%20type/borrow_user.dart';
import 'package:werehouse_inventory/screeen/user_stuff/each_category.dart';
import 'package:werehouse_inventory/shered_data_to_root/auth_service.dart';
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
      final prefs = await SharedPreferences.getInstance();
      final getToken = prefs.getString('hasBorrow');
      wsHelper.sendMessage(
        {
          "endpoint": "waitPermision",
          "data": {
            "name": getToken ?? "",
          }
        },
      );

      await for (var data in wsHelper.streamControllerAll.stream) {
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
    final authService = Provider.of<AuthService>(context, listen: true);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder(
        stream: authService.dataLocalUserHasBorrow(),
        builder: (context, snapshot) {
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

                return ListView(
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 30),
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
                    Padding(
                      padding:
                          EdgeInsets.only(left: constraints.maxWidth * 0.01),
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          nameTitle(
                            constraints,
                            context,
                            snapshot.data!.nameUser!,
                          ),
                          nameTitle(
                            constraints,
                            context,
                            snapshot.data!.classUser!,
                          ),
                          nameTitle(
                            constraints,
                            context,
                            snapshot.data!.nisn!,
                          ),
                          nameTitle(
                            constraints,
                            context,
                            snapshot.data!.status ?? "----",
                          ),
                          nameTitle(
                            constraints,
                            context,
                            snapshot.data!.nameTeacher!,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withGreen(30),
                              borderRadius: BorderRadius.circular(5.5),
                            ),
                            child: TextButton(
                              onPressed: () =>
                                  detailUser(context, snapshot.data!),
                              child: Text(
                                "Daftar Item Dipinjam",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 30, bottom: 50),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withGreen(160),
                              borderRadius: BorderRadius.circular(5.5),
                            ),
                            child: TextButton(
                              onPressed: () => authService.wsHelper.sendMessage(
                                {
                                  "endpoint": "waitPermision",
                                  "data": {
                                    "name": "${snapshot.data!.nameUser}",
                                  },
                                },
                              ),
                              child: Text(
                                "kembalikan item",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
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
      ),
    );
  }

  Container nameTitle(
      BoxConstraints constraints, BuildContext context, String title) {
    return Container(
      margin: EdgeInsets.only(
          left: constraints.maxWidth * 0.025,
          bottom: constraints.maxWidth * 0.02),
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(5.5)),
      height: constraints.maxWidth * 0.065,
      width: constraints.maxWidth * 0.6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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

  void detailUser(BuildContext context, BorrowUser dataItem) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        contentPadding: EdgeInsets.only(top: 10.0),
        title: Column(
          children: [
            Row(
              children: [
                Text(
                  "${dataItem.nameUser}".toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 30,
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                "List Item Borrow",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (dataItem.time != null)
              Text(
                dataItem.time!.substring(0, 19),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 10,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "close",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        content: Container(
          margin: EdgeInsets.only(top: 10),
          height: double.maxFinite,
          width: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: dataItem.item.length,
            itemBuilder: (context, indexs) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Text(
                  dataItem.item[indexs].index,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 15,
                  ),
                ),
              ),
              title: Text(
                dataItem.item[indexs].category,
                style: TextStyle(fontSize: 12),
              ),
              subtitle: Text(
                dataItem.item[indexs].nameItem,
                style: TextStyle(fontSize: 12),
              ),
              trailing: Text(
                dataItem.item[indexs].label,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
