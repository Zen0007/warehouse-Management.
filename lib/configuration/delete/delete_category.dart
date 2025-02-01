import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/configuration/delete/controler_service_deleted.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class DeleteCategory extends StatefulWidget {
  const DeleteCategory({super.key});

  @override
  State<DeleteCategory> createState() => _AddItemState();
}

class _AddItemState extends State<DeleteCategory> {
  final textField = FocusNode();
  bool isLoding = false;
  bool obscureText = true;

  String? valueDropDown;

  void toggleObscure() {
    setState(() {
      obscureText = !obscureText;
      textField.canRequestFocus = false;
    });
  }

  Future<dynamic> alertIfNull(String title) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void sumbit(BuildContext context, WebsocketHelper wsHelper) async {
    try {
      setState(
        () {
          isLoding = true;
        },
      );

      if (valueDropDown == null) {
        alertIfNull('category must add');
        return;
      }

      wsHelper.sendMessage(
        {
          "endpoint": "deleteCategory",
          "data": {
            "category": valueDropDown,
          },
        },
      );

      await for (var data in wsHelper.streamController.stream) {
        if (data['endpoint'] == "DELETECATEGORY") {
          if (data.containsKey("warning")) {
            final warning = data['message'];

            if (!context.mounted) return;
            messageFromServer(
              warning,
              true,
              Theme.of(context).colorScheme.error,
            );
            setState(
              () {
                isLoding = false;
              },
            );

            return;
          }
          if (data.containsKey('message')) {
            final message = data['message'];

            if (!context.mounted) return;
            messageFromServer(
              message,
              true,
              Theme.of(context).colorScheme.surface,
            );
            setState(
              () {
                isLoding = false;
                valueDropDown = null;
              },
            );
          }
        }
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<dynamic> messageFromServer(message, bool isMessage, Color color) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor: color,
        title: Text(
          isMessage ? 'MESSAGE' : 'WARNING',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          "$message",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () {
              Navigator.pop(context);

              setState(
                () {
                  isLoding = false;
                },
              );
            },
            child: Text(
              "Yes",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onError,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          debugPrint('${constraints.maxWidth} screen');
          if (constraints.maxWidth < 880) {
            return smallScreen(constraints, context);
          } else {
            return largeScreen(constraints, context);
          }
        },
      ),
      floatingActionButton: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ControllerServiceDeleted(),
            ),
          );
        },
        child: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
      ),
    );
  }

  ListView smallScreen(BoxConstraints constraints, BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: constraints.maxWidth * 0.2,
            left: constraints.maxWidth * 0.2,
            top: constraints.maxWidth * 0.3,
            bottom: 10,
          ),
          child: FormField(
            builder: (FormFieldState<String> state) {
              return Consumer<WebsocketHelper>(
                builder: (context, wsHelper, child) {
                  // listen database
                  wsHelper.getAllKeyCategory();

                  return FutureBuilder(
                    future: wsHelper.keyCategory(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      } else if (snapshot.data!.isEmpty) {
                        return Center(
                          child: ListTile(
                            title: Text(
                              "Daftar category kosong ",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasData) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            errorStyle: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          isEmpty: valueDropDown == null,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              hint: valueDropDown == null
                                  ? Text(
                                      "Pilih Category Item",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    )
                                  : Text(
                                      "$valueDropDown",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                              onChanged: (value) {
                                setState(
                                  () {
                                    valueDropDown = value!.key;
                                    state.didChange(value.key);
                                  },
                                );
                              },
                              isDense: true,
                              items: snapshot.data!.map(
                                (selected) {
                                  return DropdownMenuItem(
                                    value: selected,
                                    child: Text(
                                      selected.key,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        );
                      } else {
                        return ListTile(
                          title: Text(
                            "${snapshot.error}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
        if (isLoding)
          Container(
            padding: EdgeInsets.only(
              right: constraints.maxWidth * 0.2,
              left: constraints.maxWidth * 0.2,
              top: constraints.maxWidth * 0.18,
              bottom: 2,
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Center(
                child: Text(
                  "Lodding...",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        if (!isLoding)
          Container(
            padding: EdgeInsets.only(
              right: constraints.maxWidth * 0.2,
              left: constraints.maxWidth * 0.2,
              top: constraints.maxWidth * 0.18,
              bottom: 20,
            ),
            child:
                Consumer<WebsocketHelper>(builder: (context, wsHelper, child) {
              return ElevatedButton(
                onPressed: () {
                  // for summbit ------------------------------------------------
                  sumbit(context, wsHelper);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: const Center(
                  child: Text(
                    "Sumbit",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }

  ListView largeScreen(BoxConstraints constraints, BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: constraints.maxWidth * 0.3,
            left: constraints.maxWidth * 0.3,
            top: constraints.maxWidth * 0.3,
            bottom: 10,
          ),
          child: FormField(builder: (FormFieldState<String> state) {
            return Consumer<WebsocketHelper>(
              builder: (context, wsHelper, child) {
                // listen database
                wsHelper.getAllKeyCategory();

                return FutureBuilder(
                  future: wsHelper.keyCategory(),
                  builder: (context, snapshot) {
                    print(snapshot.data);
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else if (snapshot.data!.isEmpty) {
                      return Center(
                        child: ListTile(
                          title: Text(
                            "Daftar category kosong ",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasData) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          errorStyle: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        isEmpty: valueDropDown == null,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            hint: valueDropDown == null
                                ? Text(
                                    "Pilih Category Item",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  )
                                : Text(
                                    "$valueDropDown",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                            onChanged: (value) {
                              setState(
                                () {
                                  valueDropDown = value!.key;
                                  state.didChange(value.key);
                                },
                              );
                            },
                            isDense: true,
                            items: snapshot.data!.map(
                              (selected) {
                                return DropdownMenuItem(
                                  value: selected,
                                  child: Text(
                                    selected.key,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      );
                    } else {
                      return ListTile(
                        title: Text(
                          "${snapshot.error}",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }),
        ),
        if (isLoding)
          Container(
            padding: EdgeInsets.only(
              right: constraints.maxWidth * 0.3,
              left: constraints.maxWidth * 0.3,
              top: constraints.maxWidth * 0.1,
              bottom: 20,
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Center(
                child: Text(
                  "Lodding...",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        if (!isLoding)
          Container(
            padding: EdgeInsets.only(
              right: constraints.maxWidth * 0.3,
              left: constraints.maxWidth * 0.3,
              top: constraints.maxWidth * 0.1,
              bottom: 20,
            ),
            child: Consumer<WebsocketHelper>(
              builder: (context, wsHelper, child) {
                return ElevatedButton(
                  onPressed: () {
                    // for summbit ------------------------------------------------
                    sumbit(context, wsHelper);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Center(
                    child: Text(
                      "Sumbit",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
