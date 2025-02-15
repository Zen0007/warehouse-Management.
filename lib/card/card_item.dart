import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/data%20type/index.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class CardItem extends StatelessWidget {
  const CardItem({
    super.key,
    required this.data,
    required this.imageSize,
  });

  final Index data;
  final double imageSize;

  Future<dynamic> messages(BuildContext context, bool isMessage,
      String response, Color color, Color backgroundColor) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor: backgroundColor,
        title: Text(
          isMessage ? "MESSAGE" : "WARNING",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          response,
          style: TextStyle(
            color: color,
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
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void deletedItem(BuildContext context, WebsocketHelper wsHelper) async {
    await for (final message in wsHelper.deleteItem.stream) {
      if (message.containsKey('message')) {
        if (!context.mounted) return;
        messages(
          context,
          true,
          message['message'],
          Theme.of(context).colorScheme.onSurface,
          Theme.of(context).colorScheme.surface,
        );
        return;
      } else {
        if (!context.mounted) return;
        messages(
          context,
          true,
          message['warning'],
          Theme.of(context).colorScheme.onError,
          Theme.of(context).colorScheme.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(data.index),
      color: Theme.of(context).colorScheme.secondary,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (data.image.isNotEmpty)
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
                      data.image,
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
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "name :",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    data.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "label   :",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    data.label,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "status :",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    data.status,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ],
          ),
          Positioned(
            right: 5,
            bottom: 10,
            child: Consumer<WebsocketHelper>(
              builder: (context, wsHelper, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        wsHelper.sendMessage({
                          'endpoint': "deleteItem",
                          'data': {
                            'category': data.category,
                            'index': data.index,
                          }
                        });

                        deletedItem(context, wsHelper);
                      },
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      icon: Icon(
                        Icons.remove_circle_outline,
                        size: 30,
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
