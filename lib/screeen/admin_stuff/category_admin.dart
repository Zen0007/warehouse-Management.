import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/card/card_item.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class ScreenCategoryAdmin extends StatelessWidget {
  const ScreenCategoryAdmin({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          title,
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
          //listener database
          wsHelper.getDataAllCollection();

          return StreamBuilder(
            stream: wsHelper.indexCategoryForAdmin(title),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isNotEmpty) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int count;
                      double mainAxisExtent;
                      print(constraints.maxWidth);

                      if (constraints.maxWidth < 480) {
                        count = 2;
                        mainAxisExtent = constraints.maxWidth * 0.67;
                      } else if (constraints.maxWidth < 700) {
                        count = 3;
                        mainAxisExtent = constraints.maxWidth * 0.5;
                      } else if (constraints.maxWidth < 900) {
                        count = 4;
                        mainAxisExtent = constraints.maxWidth * 0.35;
                      } else if (constraints.maxWidth < 1000) {
                        count = 5;
                        mainAxisExtent = constraints.maxWidth * 0.3;
                      } else {
                        count = 6;
                        mainAxisExtent = constraints.maxWidth * 0.25;
                      }

                      double sizeImage = constraints.maxWidth / count;
                      return GridView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        padding: const EdgeInsets.all(10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: count,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 1,
                          mainAxisExtent: mainAxisExtent,
                        ),
                        itemBuilder: (context, index) {
                          return CardItem(
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
                      ),
                    ),
                  );
                }
              } else if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
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
    );
  }
}
