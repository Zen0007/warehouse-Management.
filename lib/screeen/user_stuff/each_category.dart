import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/card/card_item_user.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class ScreenCategoryUser extends StatefulWidget {
  const ScreenCategoryUser({super.key, required this.title});
  final String title;

  @override
  State<ScreenCategoryUser> createState() => _ScreenCategoryUserState();
}

class _ScreenCategoryUserState extends State<ScreenCategoryUser> {
  @override
  Widget build(BuildContext context) {
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
        builder: (contex, wsHelper, _) {
          return StreamBuilder(
            stream: wsHelper.streamCollectionAvaileble.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'not have item',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                );
              }

              if (snapshot.hasData) {
                final index =
                    wsHelper.processForUser(snapshot.data!, widget.title);
                return LayoutBuilder(
                  builder: (context, constraints) {
                    int count;
                    double mainAxisExtent;
                    print(constraints.maxWidth);

                    if (constraints.maxWidth < 400) {
                      count = 1;
                      mainAxisExtent = constraints.maxWidth * 1.5;
                    } else if (constraints.maxWidth < 500) {
                      count = 2;
                      mainAxisExtent = constraints.maxWidth * 0.75;
                    } else if (constraints.maxWidth < 600) {
                      count = 2;
                      mainAxisExtent = constraints.maxWidth * 0.7;
                    } else if (constraints.maxWidth < 700) {
                      count = 3;
                      mainAxisExtent = constraints.maxWidth * 0.5;
                    } else if (constraints.maxWidth < 900) {
                      count = 4;
                      mainAxisExtent = constraints.maxWidth * 0.4;
                    } else if (constraints.maxWidth < 1000) {
                      count = 5;
                      mainAxisExtent = constraints.maxWidth * 0.35;
                    } else if (constraints.maxWidth < 1200) {
                      count = 5;
                      mainAxisExtent = constraints.maxWidth * 0.3;
                    } else if (constraints.maxWidth > 1200) {
                      count = 6;
                      mainAxisExtent = constraints.maxWidth * 0.25;
                    } else {
                      count = 6;
                      mainAxisExtent = constraints.maxWidth * 0.29;
                    }

                    double sizeImage = constraints.maxWidth / count;
                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: index.length,
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: count,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 1,
                        mainAxisExtent: mainAxisExtent,
                      ),
                      itemBuilder: (context, indexs) {
                        return CardItemUser(
                          data: index[indexs],
                          imageSize: sizeImage,
                          size: constraints,
                        );
                      },
                    );
                  },
                );
              } else {
                return Center(
                  child: Center(
                    child: Text(
                      "${snapshot.error}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
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
