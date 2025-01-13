import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class AddNewAdmin extends StatefulWidget {
  const AddNewAdmin({super.key});

  @override
  State<AddNewAdmin> createState() => _AddNewAdminState();
}

class _AddNewAdminState extends State<AddNewAdmin> {
  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();
  final textField = FocusNode();
  String name = '';
  bool isLoding = false;
  String password = '';
  bool obscureText = true;

  void toggleObscure() {
    setState(() {
      obscureText = !obscureText;
      textField.canRequestFocus = false;
    });
  }

  void sumbit(BuildContext context, WebsocketHelper wsHelper) async {
    final validate = _fromKey.currentState!.validate();
    final prefs = await SharedPreferences.getInstance();
    // ignore: unused_local_variable
    final nameAdmin = prefs.getString('token');

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

      wsHelper.sendMessage(
        {
          "endpoint": "register",
          "data": {
            "name": name,
            "password": password,
            "nameAdd": nameAdmin,
          },
        },
      );

      await for (var data in wsHelper.streamController.stream) {
        if (data['endpoint'] == "RIGISTER") {
          if (data.containsKey("warning")) {
            final warning = data['warning'];
            if (!context.mounted) return;
            alertDialog(context, warning);

            debugPrint("$warning waring");
            return;
          } else if (data.containsKey('message')) {
            if (!context.mounted) return;
            final message = data['message'];
            message(context, message);
          }
        }
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<dynamic> message(BuildContext context, message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'MESSAGE',
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
            onPressed: () => Navigator.pop(context),
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

  Future<dynamic> alertDialog(BuildContext context, warning) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor: Theme.of(context).colorScheme.error,
        title: Text(
          "WARNING",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onError,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          "$warning",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onError,
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
              Future.delayed(
                Duration(seconds: 1),
                () {
                  _fromKey.currentState!.reset();
                  setState(
                    () {
                      isLoding = false;
                    },
                  );
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
    return LayoutBuilder(
      builder: (context, constraints) {
        debugPrint("${constraints.maxWidth}");

        if (constraints.maxWidth < 800) {
          return mobile(context, constraints);
        } else {
          return desktop(context, constraints);
        }
      },
    );
  }

  Column desktop(BuildContext context, BoxConstraints constraints) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: EdgeInsets.only(
              right: constraints.maxWidth * 0.25,
              left: constraints.maxWidth * 0.25,
              top: constraints.maxWidth * 0.05,
            ),
            child: Form(
              key: _fromKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: " new admin",
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
                        child: Icon(Icons.account_circle_sharp),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    autocorrect: true,
                    textCapitalization: TextCapitalization.none,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a valid name';
                      }
                      return null;
                    },
                    onSaved: (newValue) => name = newValue ?? "",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    obscureText: obscureText,
                    textCapitalization: TextCapitalization.none,
                    focusNode: textField,
                    decoration: InputDecoration(
                      hintText: ' password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Theme.of(context).colorScheme.secondary,
                      filled: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Icon(Icons.lock_outline_rounded),
                      ),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: toggleObscure,
                          child: Icon(
                            !obscureText
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty || value.length < 4) {
                        return 'Password must be at least 6 characters long.';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      password = newValue ?? '';
                    },
                  )
                ],
              ),
            ),
          ),
        ),
        if (isLoding)
          Container(
            padding: EdgeInsets.only(
              right: constraints.maxWidth * 0.15,
              left: constraints.maxWidth * 0.15,
              top: constraints.maxWidth * 0.3,
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
              right: constraints.maxWidth * 0.15,
              left: constraints.maxWidth * 0.15,
              top: constraints.maxWidth * 0.3,
              bottom: 20,
            ),
            child: Consumer<WebsocketHelper>(
              builder: (contex, wsHelper, child) {
                return ElevatedButton(
                  onPressed: () => sumbit(context, wsHelper),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Center(
                    child: Text(
                      "Add Admin",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
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

  Column mobile(BuildContext context, BoxConstraints constraints) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: constraints.maxWidth * 0.1,
            left: constraints.maxWidth * 0.1,
            top: constraints.maxWidth * 0.05,
          ),
          child: Form(
            key: _fromKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    hintText: " new admin",
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
                      child: Icon(Icons.account_circle_sharp),
                    ),
                  ),
                  keyboardType: TextInputType.name,
                  autocorrect: true,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                  onSaved: (newValue) => name = newValue ?? '',
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  obscureText: obscureText,
                  textCapitalization: TextCapitalization.none,
                  focusNode: textField,
                  decoration: InputDecoration(
                    hintText: ' password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Theme.of(context).colorScheme.secondary,
                    filled: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(Icons.lock_outline_rounded),
                    ),
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: toggleObscure,
                        child: Icon(
                          !obscureText
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 6) {
                      return 'Password must be at least 6 characters long.';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    password = newValue ?? '';
                  },
                ),
              ],
            ),
          ),
        ),
        if (isLoding)
          Container(
            padding: EdgeInsets.only(
              right: constraints.maxWidth * 0.15,
              left: constraints.maxWidth * 0.15,
              top: constraints.maxWidth * 0.3,
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
              right: constraints.maxWidth * 0.15,
              left: constraints.maxWidth * 0.15,
              top: constraints.maxWidth * 0.3,
              bottom: 20,
            ),
            child: Consumer<WebsocketHelper>(
              builder: (contex, wsHelper, child) {
                return ElevatedButton(
                  onPressed: () => sumbit(context, wsHelper),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Center(
                    child: Text(
                      "Add Admin",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
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
