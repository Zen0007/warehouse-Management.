import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/data type/borrow_user.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class CardBorrow extends StatelessWidget {
  const CardBorrow({
    super.key,
    required this.data,
    required this.imageSize,
  });

  final BorrowUser data;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(data.time),
      color: Theme.of(context).colorScheme.secondary,
      child: Stack(
        children: [
          Column(
            children: [
              if (data.imageUser.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(
                    top: 10,
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        // color: Theme.of(context).colorScheme.primary,
                        blurRadius: 10,
                        offset: Offset(0, 10),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      data.imageUser,
                      height: imageSize * 0.65,
                      width: imageSize * 0.8,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: imageSize * 0.65,
                  width: imageSize * 0.8,
                  margin: const EdgeInsets.only(
                    top: 10,
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 50,
                    ),
                  ),
                ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "name",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "kelas",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "guru",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "nisn",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "status",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (data.admin!.isNotEmpty)
                          Text(
                            "admin",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "${data.nameUser}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          "${data.nameTeacher}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          "${data.classUser}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          "${data.nisn}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          "${data.status}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        if (data.admin!.isNotEmpty)
                          Text(
                            "${data.admin}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
          Positioned(
            right: 5,
            bottom: 10,
            child: ElevatedButton(
              onPressed: () {
                detailUser(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: Text(
                "detail",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          Positioned(
            right: 1.5,
            top: 0.5,
            child: Consumer<WebsocketHelper>(
              builder: (context, wsHelper, child) {
                return InkWell(
                  child: Icon(
                    Icons.backup,
                    color: const Color.fromARGB(255, 253, 253, 253),
                    size: 40,
                  ),
                  onTap: () {
                    wsHelper.sendMessage(
                      {
                        "endpoint": "waitPermision",
                        'data': {
                          "name": data.nameUser ?? '',
                        }
                      },
                    );
                    deletedUserGratend(context, wsHelper);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void deletedUserGratend(
      BuildContext context, WebsocketHelper wsHelper) async {
    await for (final message in wsHelper.streamControllerAll.stream) {
      if (message['endpoint'] == "WAITPERMISION") {
        if (message.containsKey('message')) {
          if (!context.mounted) return;
          messages(
            context,
            true,
            message['message'],
            Theme.of(context).colorScheme.onSurface,
          );
          return;
        } else {
          if (!context.mounted) return;
          messages(
            context,
            true,
            message['warning'],
            Theme.of(context).colorScheme.onError,
          );
        }
      }
    }
  }

  Future<dynamic> messages(BuildContext context, bool isMessage,
      String response, Color backgroundColor) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor: backgroundColor,
        title: Text(
          isMessage ? "MESSAGE" : "WARNING",
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

  void detailUser(BuildContext context) {
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
                  "${data.nameUser}".toUpperCase(),
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
            if (data.time != null)
              Text(
                data.time!.substring(0, 19),
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
            itemCount: data.item.length,
            itemBuilder: (context, indexs) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Text(
                  data.item[indexs].index,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 15,
                  ),
                ),
              ),
              title: Text(
                data.item[indexs].category,
                style: TextStyle(fontSize: 12),
              ),
              subtitle: Text(
                data.item[indexs].nameItem,
                style: TextStyle(fontSize: 12),
              ),
              trailing: Text(
                data.item[indexs].label,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
