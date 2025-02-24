import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/configuration/add_data/add_new_admin.dart';
import 'package:werehouse_inventory/configuration/add_data/add_category.dart';
import 'package:werehouse_inventory/configuration/add_data/add_item.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class ControllerService extends StatelessWidget {
  const ControllerService({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      animationDuration: Duration(seconds: 1),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            "Delete Controller",
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Consumer<WebsocketHelper>(
              builder: (context, wsHelper, _) {
                print("width screen ${constraints.maxWidth}");
                return rowListController(context, constraints, wsHelper);
              },
            );
          },
        ),
      ),
    );
  }

  Row rowListController(BuildContext context, BoxConstraints constraints,
      WebsocketHelper wsHelper) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewAdmin(),
              ),
            );
          },
          child: listController(constraints, 'New Admin'),
        ),
        InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AddCategory(),
              ),
            );
          },
          child: listController(constraints, 'New Category'),
        ),
        InkWell(
          onTap: () {
            wsHelper.getAllKeyCategoryOnce(); // only once call
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AddItem(),
              ),
            );
          },
          child: listController(constraints, 'New Item'),
        ),
      ],
    );
  }

  Container listController(BoxConstraints constraints, String title) {
    return Container(
      height: constraints.maxWidth * 0.15,
      width: constraints.maxWidth * 0.3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF00BCD4),
            Color(0xFF80CBC4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(
        top: constraints.maxWidth * 0.05,
        bottom: constraints.maxWidth * 0.02,
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: constraints.maxWidth * 0.03,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
