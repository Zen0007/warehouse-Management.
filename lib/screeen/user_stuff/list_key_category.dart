import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/screeen/user_stuff/each_category.dart';
import 'package:werehouse_inventory/screeen/user_stuff/category_grid_item.dart';
import 'package:werehouse_inventory/screeen/user_stuff/list_stuffs_user.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class ListCategoryUser extends StatelessWidget {
  const ListCategoryUser({super.key});

  void selectCategory(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScreenCategoryUser(
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final frequentRequest = Provider.of<WebsocketHelper>(context, listen: true);
    frequentRequest.getAllKeyCategory();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          "List Category",
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
        builder: (contex, wsHelper, _) {
          return StreamBuilder(
            stream: wsHelper.streamKeyResult.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              } else if (snapshot.hasData) {
                final keyList = wsHelper.processKey(snapshot.data!);
                if (keyList.isEmpty) {
                  return Center(
                    child: Text(
                      'data is empty',
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

                    // double sizeImage = constraints.maxWidth / count;

                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: keyList.length,
                      padding: const EdgeInsets.all(20),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: count,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 8,
                        mainAxisExtent: mainAxisExtent,
                      ),
                      itemBuilder: (context, index) {
                        return CategoryGridItem(
                          title: keyList[index],
                          onSelectCategory: () {
                            wsHelper
                                .getDataCategoryUserOnce(); // triger ws send data
                            selectCategory(
                              context,
                              keyList[index].key,
                            );
                          },
                        );
                      },
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
          );
        },
      ),
    );
  }
}
