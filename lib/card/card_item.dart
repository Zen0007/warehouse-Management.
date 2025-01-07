import 'package:flutter/material.dart';
import 'package:werehouse_inventory/dummy_data/decode.dart';
import 'package:werehouse_inventory/shered_data_to_root/shared_preferences.dart';

class CardItem extends StatelessWidget {
  const CardItem({
    super.key,
    required this.data,
    required this.imageSize,
  }) : isUser = false;

  const CardItem.forUser({
    super.key,
    required this.data,
    required this.imageSize,
    required this.isUser,
  });

  final Index data;
  final double imageSize;
  final bool isUser;

  Future<void> store(
    String category,
    String index,
    String name,
    String label,
  ) async {
    // await StoredUserChoice().delete();
    await StoredUserChoice().addNewMapToSharedPreferences(
      {
        "category": category,
        "index": index,
        "nameItem": name,
        "label": label,
      },
    );
    final dataShow = await StoredUserChoice().getListFromSharedPreferences();

    debugPrint("$dataShow data");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(
              top: 10,
              bottom: 8,
            ),
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  // color: Theme.of(context).colorScheme.primary,
                  blurRadius: 10,
                  offset: Offset(0, 10),
                ),
              ],
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                "assets/data/black_bull.jpeg",
                height: imageSize * 0.65,
                width: imageSize * 0.8,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "name :",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                data.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "label   :",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                data.label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          if (!isUser)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "status :",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  data.status,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          Spacer(),
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(bottom: 5, right: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => store(
                      data.category,
                      data.index,
                      data.name,
                      data.label,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    icon: Icon(
                      Icons.bookmark_add_outlined,
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
