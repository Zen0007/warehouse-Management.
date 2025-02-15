import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/card/card_borrow.dart';
import 'package:werehouse_inventory/data%20type/borrow_user.dart';

import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class BorrowUserPage extends StatefulWidget {
  const BorrowUserPage({super.key});

  @override
  State<BorrowUserPage> createState() => _BorrowUserPageState();
}

class _BorrowUserPageState extends State<BorrowUserPage> {
  @override
  Widget build(BuildContext context) {
    final secondaryWs = Provider.of<WebsocketHelper>(context, listen: true);
    secondaryWs.getDataBorrow();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          "Daftar  Peminjam",
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
            stream: wsHelper.streamBorrow.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              } else if (snapshot.hasData) {
                final List<BorrowUser> listBorrow =
                    wsHelper.processBorrow(snapshot.data!);

                if (listBorrow.isEmpty) {
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
                    debugPrint("${constraints.maxWidth} size");
                    if (constraints.maxWidth < 400) {
                      count = 1;
                      mainAxisExtent = constraints.maxWidth * 1.4;
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
                      mainAxisExtent = constraints.maxWidth * 0.44;
                    } else if (constraints.maxWidth < 1000) {
                      count = 4;
                      mainAxisExtent = constraints.maxWidth * 0.4;
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
                      itemCount: listBorrow.length,
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: count,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 1,
                        mainAxisExtent: mainAxisExtent,
                      ),
                      itemBuilder: (context, index) {
                        return CardBorrow(
                          data: listBorrow[index],
                          imageSize: sizeImage,
                        );
                      },
                    );
                  },
                );
              }
              return Center(
                  child: Center(
                child: Text(
                  "${snapshot.error}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ));
            },
          );
        },
      ),
    );
  }
}
