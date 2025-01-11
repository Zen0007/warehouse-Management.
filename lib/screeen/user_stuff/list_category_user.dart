import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/screeen/user_stuff/category_user.dart';
import 'package:werehouse_inventory/screeen/user_stuff/category_grid_item.dart';
import 'package:werehouse_inventory/screeen/user_stuff/list_stuff_user.dart';
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
            stream: wsHelper.keyCategory().asStream(),
            builder: (context, snapshot) {
              print("${snapshot.data} data key for user list");
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              } else if (snapshot.hasData) {
                if (snapshot.data!.isNotEmpty) {
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
                        itemCount: snapshot.data!.length,
                        padding: const EdgeInsets.all(20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: count,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 8,
                          mainAxisExtent: mainAxisExtent,
                        ),
                        itemBuilder: (context, index) {
                          return CategoryGridItem(
                            title: snapshot.data![index],
                            onSelectCategory: () {
                              wsHelper
                                  .getDataCategoryUser(); // triger ws send data
                              selectCategory(
                                context,
                                snapshot.data![index].key,
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
    );
  }
}
