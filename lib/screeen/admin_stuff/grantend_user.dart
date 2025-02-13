import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/card/card_granted.dart';
import 'package:werehouse_inventory/data%20type/borrow_user.dart';
import 'package:werehouse_inventory/data%20type/item.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class GrantendUser extends StatefulWidget {
  const GrantendUser({super.key});

  @override
  State<GrantendUser> createState() => _GrantendUserState();
}

class _GrantendUserState extends State<GrantendUser> {
  final List<BorrowUser> dymmyData = [
    BorrowUser(
      imageUser: Uint8List.fromList([]),
      item: [
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        )
      ],
      admin: 'super',
      classUser: "xxx",
      imageNisn: [],
      nameTeacher: "zamzam",
      nameUser: "bagas",
      nisn: "12234",
      status: "return",
      time: "${DateTime.now()}",
    ),
    BorrowUser(
      imageUser: Uint8List.fromList([]),
      item: [
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        )
      ],
      admin: 'super',
      classUser: "xxx",
      imageNisn: [],
      nameTeacher: "zamzam",
      nameUser: "bagas",
      nisn: "12234",
      status: "return",
      time: "${DateTime.now()}",
    ),
    BorrowUser(
      imageUser: Uint8List.fromList([]),
      item: [
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        )
      ],
      admin: 'super',
      classUser: "xxx",
      imageNisn: [],
      nameTeacher: "zamzam",
      nameUser: "bagas",
      nisn: "12234",
      status: "return",
      time: "${DateTime.now()}",
    ),
    BorrowUser(
      imageUser: Uint8List.fromList([]),
      item: [
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        )
      ],
      admin: 'super',
      classUser: "xxx",
      imageNisn: [],
      nameTeacher: "zamzam",
      nameUser: "bagas",
      nisn: "12234",
      status: "return",
      time: "${DateTime.now()}",
    ),
    BorrowUser(
      imageUser: Uint8List.fromList([]),
      item: [
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        )
      ],
      admin: 'super',
      classUser: "xxx",
      imageNisn: [],
      nameTeacher: "zamzam",
      nameUser: "bagas",
      nisn: "12234",
      status: "return",
      time: "${DateTime.now()}",
    ),
    BorrowUser(
      imageUser: Uint8List.fromList([]),
      item: [
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        )
      ],
      admin: 'super',
      classUser: "xxx",
      imageNisn: [],
      nameTeacher: "zamzam",
      nameUser: "bagas",
      nisn: "12234",
      status: "return",
      time: "${DateTime.now()}",
    ),
    BorrowUser(
      imageUser: Uint8List.fromList([]),
      item: [
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        ),
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        ),
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        ),
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        ),
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        ),
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        ),
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        ),
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        ),
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        ),
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        ),
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        ),
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        ),
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        ),
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        ),
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        ),
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        ),
        Item(
          category: "mikrotik",
          index: "1",
          nameItem: "acee",
          label: "488",
        )
      ],
      admin: 'super',
      classUser: "xxx",
      imageNisn: [],
      nameTeacher: "zamzam",
      nameUser: "bagas",
      nisn: "12234",
      status: "return",
      time: "${DateTime.now()}",
    )
  ];

  @override
  Widget build(BuildContext context) {
    final secondaryWs = Provider.of<WebsocketHelper>(context, listen: true);
    secondaryWs.getDataGranted();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          "Daftar  Pengembalian",
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
      body: test(),
    );
  }

  LayoutBuilder testtwo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        print("${constraints.maxWidth} granted");
        int count;
        double mainAxisExtent;
        debugPrint("${constraints.maxWidth} size");
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
          itemCount: dymmyData.length,
          padding: const EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            mainAxisSpacing: 8,
            crossAxisSpacing: 1,
            mainAxisExtent: mainAxisExtent,
          ),
          itemBuilder: (context, index) {
            return CardGranted(
              data: dymmyData[index],
              imageSize: sizeImage,
            );
          },
        );
      },
    );
  }

  Consumer<WebsocketHelper> test() {
    return Consumer<WebsocketHelper>(
      builder: (contex, wsHelper, child) {
        return StreamBuilder(
          stream: wsHelper.streamGranted.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator.adaptive(),
              );
            } else if (snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'data is empty',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              final List<BorrowUser> listGrated =
                  wsHelper.processGranted(snapshot.data!);
              return LayoutBuilder(
                builder: (context, constraints) {
                  print("${constraints.maxWidth} granted");
                  int count;
                  double mainAxisExtent;
                  debugPrint("${constraints.maxWidth} size");
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
                    itemCount: listGrated.length,
                    padding: const EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: count,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 1,
                      mainAxisExtent: mainAxisExtent,
                    ),
                    itemBuilder: (context, index) {
                      return CardGranted(
                        data: listGrated[index],
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
    );
  }
}
