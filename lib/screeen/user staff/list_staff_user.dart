import 'package:flutter/material.dart';
import 'package:werehouse_inventory/screeen/user%20staff/form_user_borrow.dart';
import 'package:werehouse_inventory/shered_data_to_root/shared_preferences.dart';

class ListStaffUser extends StatefulWidget {
  const ListStaffUser({super.key});

  @override
  State<ListStaffUser> createState() => _ListStaffUserState();
}

class _ListStaffUserState extends State<ListStaffUser> {
  void delete(String title) async {
    await StoredUserChoice().deleteItem(title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          "Daftar  Peminjaman",
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
      body: StreamBuilder(
        stream: StoredUserChoice().getListFromSharedPreferences().asStream(),
        builder: (context, snapShot) {
          if (!snapShot.hasData) {
            return Center(
              child: Text("Harap Pilih Barang yang Akan Di Pinjam"),
            );
          } else if (snapShot.hasData) {
            if (snapShot.data!.isEmpty) {
              return Center(
                child: Text(
                  "Harap Pilih Barang yang Akan Di Pinjam",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                return ListView.builder(
                  itemCount: snapShot.data!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(
                        top: constraints.maxWidth * 0.02,
                        bottom: constraints.maxWidth * 0.02,
                        left: constraints.maxWidth * 0.025,
                        right: constraints.maxWidth * 0.025,
                      ),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(5.5)),
                      height: constraints.maxWidth * 0.12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: constraints.maxWidth * 0.02,
                          ),
                          Container(
                            height: constraints.maxWidth * 0.08,
                            width: constraints.maxWidth * 0.08,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Center(
                              child: Text(
                                "${snapShot.data![index]['index']}",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: constraints.maxWidth * 0.035,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: constraints.maxWidth * 0.03,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${snapShot.data![index]['category']}",
                                style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.03,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(
                                height: constraints.maxWidth * 0.01,
                              ),
                              Text(
                                "${snapShot.data![index]['name']}",
                                style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.025,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: constraints.maxWidth * 0.077,
                          ),
                          Text(
                            "${snapShot.data![index]['label']}".toUpperCase(),
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.035,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () => setState(
                              () {
                                delete(snapShot.data![index]['label']);
                              },
                            ),
                            icon: Icon(
                              Icons.remove_circle_sharp,
                              size: constraints.maxWidth * 0.065,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }
          return Center(
            child: Text(
              'tidak ada item ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => FormForUser()),
        ),
        child: Icon(
          Icons.filter_list,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    );
  }
}
