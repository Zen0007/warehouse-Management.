import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class DeleteItems extends StatefulWidget {
  const DeleteItems({super.key});

  @override
  State<DeleteItems> createState() => _AddItemState();
}

class _AddItemState extends State<DeleteItems> {
  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();
  final textField = FocusNode();
  Uint8List? image;
  String index = '';
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

  void sumbit(WebsocketHelper wsHelper) async {
    final validate = _fromKey.currentState!.validate();

    if (!validate) {
      await Future.delayed(
        Duration(seconds: 5),
        () {
          _fromKey.currentState!.reset();
        },
      );
      return;
    }
    _fromKey.currentState!.save();

    try {
      setState(
        () {
          isLoding = true;
        },
      );

      if (valueDropDown == null) {
        alertIfNull('category must add');
        setState(() {
          isLoding = false;
        });
        return;
      }

      wsHelper.sendMessage(
        {
          "endpoint": "newItem",
          "data": {
            "category": valueDropDown,
            "index": index,
            "image": image,
          },
        },
      );

      await for (var data in wsHelper.streamControllerAll.stream) {
        if (data['endpoint'] == "NEWITEM") {
          if (data.containsKey("warning")) {
            if (!mounted) return;
            messageFromServer(
              data['warnig'],
              false,
              Theme.of(context).colorScheme.surface,
            );
            return;
          } else if (data.containsKey('message')) {
            if (!mounted) return;
            final message = data['message'];
            messageFromServer(
              message,
              true,
              Theme.of(context).colorScheme.surface,
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
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          "$message",
          style: TextStyle(
            color: Colors.white,
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

  void clearImage() {
    setState(() {
      image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final frequentRequest = Provider.of<WebsocketHelper>(context, listen: true);
    frequentRequest.getAllKeyCategory();

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
    );
  }

  ListView smallScreen(BoxConstraints constraints, BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: constraints.maxWidth * 0.2,
            left: constraints.maxWidth * 0.2,
            bottom: 10,
          ),
          child: FormField(
            builder: (FormFieldState<String> state) {
              return Consumer<WebsocketHelper>(
                builder: (context, wsHelper, child) {
                  return StreamBuilder(
                    stream: wsHelper.streamKeyResult.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      } else if (snapshot.hasData) {
                        final key = wsHelper.processKey(snapshot.data!);

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
                              items: key.map(
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
        Padding(
          padding: EdgeInsets.only(
            right: constraints.maxWidth * 0.2,
            left: constraints.maxWidth * 0.2,
            top: constraints.maxWidth * 0.01,
          ),
          child: Form(
            key: _fromKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    hintText: " name item",
                    counterStyle: const TextStyle(
                      backgroundColor: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Theme.of(context).colorScheme.secondary,
                    filled: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(Icons.add),
                    ),
                  ),
                  keyboardType: TextInputType.name,
                  autocorrect: true,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please fill name';
                    }
                    return null;
                  },
                  onSaved: (newValue) => index = newValue ?? '',
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
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
                  sumbit(wsHelper);
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
            bottom: 10,
          ),
          child: FormField(builder: (FormFieldState<String> state) {
            return Consumer<WebsocketHelper>(
              builder: (context, wsHelper, child) {
                return StreamBuilder(
                  stream: wsHelper.streamKeyResult.stream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else if (snapshot.hasData) {
                      final key = wsHelper.processKey(snapshot.data!);
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
                            items: key.map(
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
        Padding(
          padding: EdgeInsets.only(
            right: constraints.maxWidth * 0.3,
            left: constraints.maxWidth * 0.3,
            top: constraints.maxWidth * 0.01,
          ),
          child: Form(
            key: _fromKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    hintText: " name item",
                    counterStyle: const TextStyle(
                      backgroundColor: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Theme.of(context).colorScheme.secondary,
                    filled: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(Icons.add),
                    ),
                  ),
                  keyboardType: TextInputType.name,
                  autocorrect: true,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please fill name';
                    }
                    return null;
                  },
                  onSaved: (newValue) => index = newValue ?? '',
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
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
                    sumbit(wsHelper);
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
