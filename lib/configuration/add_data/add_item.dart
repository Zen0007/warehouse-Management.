import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:werehouse_inventory/configuration/add_data/controler_service_add.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();
  final textField = FocusNode();
  final ImagePicker picker = ImagePicker();
  Uint8List? image;
  String name = '';
  String label = '';
  bool isLoding = false;
  bool hasSend = false;
  bool obscureText = true;
  String? valueDropDown;

  void toggleObscure() {
    setState(() {
      obscureText = !obscureText;
      textField.canRequestFocus = false;
    });
  }

  void _pickerImageGalery() async {
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 20,
    );
    if (pickedImage != null) {
      final imageUint8List = await pickedImage.readAsBytes();
      setState(
        () {
          image = imageUint8List;
        },
      );
    } else {
      if (!mounted) return;
      alertIfImageNull('no image select');
    }
  }

  Future<dynamic> alertIfImageNull(String title) {
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
          setState(
            () {
              isLoding = false;
            },
          );
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
        alertIfImageNull('category must add');
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
            "name": name,
            "label": label,
            "image": [],
          },
        },
      );

      await for (var request in wsHelper.addNewData.stream) {
        if (request.containsKey('message')) {
          final message = request['message'];

          if (!mounted) {
            return;
          }
          messageFromServer(
            message,
            true,
            Theme.of(context).colorScheme.surface,
          );

          setState(
            () {
              isLoding = false;
              image = null;
              valueDropDown = null;
            },
          );
          _fromKey.currentState!.reset();
          return;
        }
        if (request.containsKey("warning")) {
          final waring = request['warning'];

          if (!mounted) {
            return;
          }
          messageFromServer(
            waring,
            false,
            Theme.of(context).colorScheme.error,
          );

          setState(
            () {
              isLoding = false;
            },
          );

          return;
        }
      }
    } catch (e, s) {
      debugPrint("$e 00");
      print("$s 99");
    }
  }

  Future<dynamic> messageFromServer(message, bool isMessage, Color color) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
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
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
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
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ControllerService(),
            ),
          );
        },
        child: Icon(Icons.arrow_back_ios_new),
      ),
    );
  }

  ListView smallScreen(BoxConstraints constraints, BuildContext context) {
    return ListView(
      children: [
        if (image == null)
          Container(
            margin: EdgeInsets.only(
              right: constraints.maxWidth * 0.2,
              left: constraints.maxWidth * 0.2,
              top: constraints.maxWidth * 0.01,
              bottom: 10,
            ),
            height: constraints.maxWidth * 0.25,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: _pickerImageGalery,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'add image ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    'image opsional',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            margin: EdgeInsets.only(
              right: constraints.maxWidth * 0.2,
              left: constraints.maxWidth * 0.2,
              top: constraints.maxWidth * 0.01,
              bottom: 10,
            ),
            height: constraints.maxWidth * 0.25,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    image ?? Uint8List(10),
                    height: constraints.maxWidth * 0.65,
                    width: constraints.maxWidth * 0.8,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: InkWell(
                    child: Icon(
                      Icons.remove_circle,
                      color: const Color.fromARGB(255, 255, 0, 0),
                      size: 30,
                    ),
                    onTap: () => clearImage(),
                  ),
                )
              ],
            ),
          ),
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
                        final listKey = wsHelper.processKey(snapshot.data!);
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
                              items: listKey.map(
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
                  onSaved: (newValue) => name = newValue ?? '',
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: " label",
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
                      child: Icon(Icons.label_important_outline_sharp),
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
                  onSaved: (newValue) => label = newValue ?? '',
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
        if (image == null)
          Container(
            margin: EdgeInsets.only(
              right: constraints.maxWidth * 0.3,
              left: constraints.maxWidth * 0.3,
              top: constraints.maxWidth * 0.01,
              bottom: 20,
            ),
            height: constraints.maxWidth * 0.2,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: _pickerImageGalery,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'add image ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    'image opsional',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            margin: EdgeInsets.only(
              right: constraints.maxWidth * 0.3,
              left: constraints.maxWidth * 0.3,
              top: constraints.maxWidth * 0.01,
              bottom: 20,
            ),
            height: constraints.maxWidth * 0.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    image ?? Uint8List(10),
                    height: constraints.maxWidth * 0.65,
                    width: constraints.maxWidth * 0.8,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: InkWell(
                    child: Icon(
                      Icons.remove_circle,
                      color: const Color.fromARGB(255, 255, 1, 1),
                      size: 40,
                    ),
                    onTap: () => clearImage(),
                  ),
                )
              ],
            ),
          ),
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
                      final listKey = wsHelper.processKey(snapshot.data!);

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
                            items: listKey.map(
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
                  onSaved: (newValue) => name = newValue ?? '',
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: " label",
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
                      child: Icon(Icons.label_important_outline_sharp),
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
                  onSaved: (newValue) => label = newValue ?? '',
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
