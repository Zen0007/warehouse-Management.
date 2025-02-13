import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/card/card_item.dart';
import 'package:werehouse_inventory/data%20type/index.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class CategoryAdmin extends StatefulWidget {
  const CategoryAdmin({super.key, required this.title});
  final String title;
  @override
  State<CategoryAdmin> createState() => _CategoryAdminState();
}

class _CategoryAdminState extends State<CategoryAdmin> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final secondaryWs = Provider.of<WebsocketHelper>(context, listen: true);
    secondaryWs.getDataAllCollection();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          widget.title,
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
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<WebsocketHelper>(
        builder: (contex, wsHelper, child) {
          return StreamBuilder(
            stream: wsHelper.streamCollectionAdmin.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              } else if (snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'item kosong',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                );
              }
              if (snapshot.hasData) {
                final List<Index> indexItem =
                    wsHelper.processIndex(widget.title, snapshot.data!) ?? [];

                if (indexItem.isEmpty) {
                  return Center(
                    child: Text(
                      'item kosong',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    int count;
                    double mainAxisExtent;
                    debugPrint("${constraints.maxWidth} ");

                    if (constraints.maxWidth < 400) {
                      count = 1;
                      mainAxisExtent = constraints.maxWidth * 1.1;
                    } else if (constraints.maxWidth < 500) {
                      count = 2;
                      mainAxisExtent = constraints.maxWidth * 0.83;
                    } else if (constraints.maxWidth < 600) {
                      count = 2;
                      mainAxisExtent = constraints.maxWidth * 0.76;
                    } else if (constraints.maxWidth < 700) {
                      count = 3;
                      mainAxisExtent = constraints.maxWidth * 0.56;
                    } else if (constraints.maxWidth < 900) {
                      count = 4;
                      mainAxisExtent = constraints.maxWidth * 0.45;
                    } else if (constraints.maxWidth < 1000) {
                      count = 5;
                      mainAxisExtent = constraints.maxWidth * 0.35;
                    } else if (constraints.maxWidth < 1200) {
                      count = 5;
                      mainAxisExtent = constraints.maxWidth * 0.34;
                    } else if (constraints.maxWidth > 1200) {
                      count = 6;
                      mainAxisExtent = constraints.maxWidth * 0.28;
                    } else {
                      count = 6;
                      mainAxisExtent = constraints.maxWidth * 0.29;
                    }

                    double sizeImage = constraints.maxWidth / count;
                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: indexItem.length,
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: count,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 1,
                        mainAxisExtent: mainAxisExtent,
                      ),
                      itemBuilder: (context, indexs) {
                        return CardItem(
                          data: indexItem[indexs],
                          imageSize: sizeImage,
                        );
                      },
                    );
                  },
                );
              } else {
                return Center(
                  child: Text(
                    'error on server ${snapshot.error}',
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
    );
  }
}
