import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/card/card_pending.dart';
import 'package:werehouse_inventory/data%20type/borrow_user.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class PendingUser extends StatelessWidget {
  const PendingUser({super.key});

  @override
  Widget build(BuildContext context) {
    final frequentRequest = Provider.of<WebsocketHelper>(context, listen: true);
    frequentRequest.getDataPending();
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
            stream: wsHelper.streamPending.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              } else if (snapshot.hasData) {
                final List<BorrowUser> listPenging =
                    wsHelper.processPending(snapshot.data!);

                if (listPenging.isEmpty) {
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
                      mainAxisExtent = constraints.maxHeight * 1.4;
                    } else if (constraints.maxWidth < 500) {
                      count = 2;
                      mainAxisExtent = constraints.maxWidth * 0.66;
                    } else if (constraints.maxWidth < 700) {
                      count = 3;
                      mainAxisExtent = constraints.maxWidth * 0.47;
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
                      itemCount: listPenging.length,
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: count,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 1,
                        mainAxisExtent: mainAxisExtent,
                      ),
                      itemBuilder: (context, index) {
                        return CardPending(
                          data: listPenging[index],
                          imageSize: sizeImage,
                        );
                      },
                    );
                  },
                );
              }
              return Center(
                child: Text(
                  "${snapshot.error}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
