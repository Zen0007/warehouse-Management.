import 'package:flutter/material.dart';
import 'package:werehouse_inventory/data type/borrow_user.dart';

class CardBorrow extends StatelessWidget {
  const CardBorrow({
    super.key,
    required this.data,
    required this.imageSize,
  });

  final BorrowUser data;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => detailUser(context),
      child: Card(
        color: Theme.of(context).colorScheme.secondary,
        child: Column(
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
                child: Image.memory(
                  data.imageUser,
                  height: imageSize * 0.65,
                  width: imageSize * 0.8,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "name",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "kelas",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "guru",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "nisn",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "status",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (data.admin != null)
                        Text(
                          "admin",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${data.nameUser}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        "${data.nameTeacher}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        "${data.classUser}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        "${data.nisn}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      Text(
                        "${data.status}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      if (data.admin != null)
                        Text(
                          "${data.admin}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void detailUser(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        contentPadding: EdgeInsets.only(top: 10.0),
        title: Column(
          children: [
            Row(
              children: [
                Text(
                  "${data.nameUser}".toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 30,
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                "List Item Borrow",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (data.time != null)
              Text(
                "${data.time}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 30,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "close",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        content: Container(
          margin: EdgeInsets.only(top: 10),
          height: double.maxFinite,
          width: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: data.item.length,
            itemBuilder: (context, indexs) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Text(
                  data.item[indexs].index,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 15,
                  ),
                ),
              ),
              title: Text(
                data.item[indexs].category,
                style: TextStyle(fontSize: 12),
              ),
              subtitle: Text(
                data.item[indexs].nameItem,
                style: TextStyle(fontSize: 12),
              ),
              trailing: Text(
                data.item[indexs].label,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
