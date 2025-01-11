import 'package:flutter/material.dart';
import 'package:werehouse_inventory/configuration/add_data/add_new_admin.dart';
import 'package:werehouse_inventory/configuration/add_data/screen_add_category.dart';
import 'package:werehouse_inventory/configuration/add_data/screen_add_item.dart';
import 'package:werehouse_inventory/configuration/add_data/tab_apbar.dart';

class ControllerService extends StatelessWidget {
  const ControllerService({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('service'),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(25),
            child: Container(
              height: 40,
              margin: EdgeInsets.only(right: 5, left: 5, bottom: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(11)),
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Color.fromARGB(255, 12, 230, 241),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                labelColor: Theme.of(context).colorScheme.onSecondary,
                unselectedLabelColor: Colors.white,
                tabs: [
                  ScreenService(title: 'Add Admin'),
                  ScreenService(title: 'Add Item'),
                  ScreenService(title: 'Add Category'),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: TabBarView(
          children: [
            /* add new admin */
            AddNewAdmin(),

            /* add new item */
            AddItem(),

            /* add new name collection category */
            AddCategory()
          ],
        ),
        floatingActionButton: FloatingActionButton.small(
          onPressed: () {},
          child: Icon(Icons.home),
        ),
      ),
    );
  }
}
