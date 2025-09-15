import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:werehouse_inventory/page/home_page.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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

  void sumbit(BuildContext context, WebsocketHelper webSocket) async {
    final validate = _fromKey.currentState!.validate();
    if (!validate) {
      await Future.delayed(
        Duration(seconds: 5),
        () {
          _fromKey.currentState!.reset();
        },
      );
      setState(
        () {
          isLoding = false;
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

      webSocket.sendMessage(
        {
          "endpoint": "login",
          "data": {
            "name": name.replaceAll(' ', ''),
            "password": password.replaceAll(' ', ''),
          },
        },
      );

      await for (var data in webSocket.responseLogin()) {
        debugPrint("logs login $data");
        if (data.containsKey("warning")) {
          final warning = data['warning'];
          if (!context.mounted) return;
          alertDialog(context, warning);

          setState(
            () {
              isLoding = false;
            },
          );
          debugPrint("$warning waring");
          return;
        } else if (data.containsKey('message')) {
          final prefs = await SharedPreferences.getInstance();
          final token = data['message'];
          await prefs.setString('token', token);
          await prefs.setString("adminName", data['adminName']);

          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("$e");
    }
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          debugPrint("${constraints.maxWidth}");

          if (constraints.maxWidth < 600) {
            return mobile(context, constraints);
          } else if (constraints.maxWidth < 850) {
            return mobile(context, constraints);
          } else {
            return Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                        child: desktop(context, constraints),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: -4,
                  left: -1,
                  child: Image.asset(
                    "assets/data/graph.png",
                    height: 150,
                    width: 150,
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }

  Column desktop(BuildContext context, BoxConstraints constraints) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: EdgeInsets.only(
              right: constraints.maxWidth * 0.05,
              left: constraints.maxWidth * 0.05,
              top: constraints.maxWidth * 0.15,
            ),
            child: Form(
              key: _fromKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: " Enter your admin",
                      counterStyle: const TextStyle(
                        backgroundColor: Colors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
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
                        return 'Please enter a valid name admin.';
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
                        borderRadius: BorderRadius.circular(18),
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
        Expanded(
          flex: 2,
          child: ListView(
            children: [
              if (isLoding)
                Container(
                  margin: EdgeInsets.only(
                    right: constraints.maxWidth * 0.05,
                    left: constraints.maxWidth * 0.05,
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    child: Center(
                      child: Text(
                        "Lodding...",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              if (!isLoding)
                Container(
                  margin: EdgeInsets.only(
                    right: constraints.maxWidth * 0.05,
                    left: constraints.maxWidth * 0.05,
                  ),
                  child: Consumer<WebsocketHelper>(
                    builder: (contex, wsHelper, _) {
                      return ElevatedButton(
                        onPressed: () => sumbit(context, wsHelper),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                        child: Center(
                          child: Text(
                            "Login",
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
          ),
        ),
      ],
    );
  }

  Column mobile(BuildContext context, BoxConstraints constraints) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Padding(
            padding: EdgeInsets.only(
              right: constraints.maxWidth * 0.12,
              left: constraints.maxWidth * 0.12,
              top: constraints.maxWidth * 0.2,
            ),
            child: Form(
              key: _fromKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: " Enter your admin",
                      counterStyle: const TextStyle(
                        backgroundColor: Colors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
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
                        return 'Please enter a valid name admin.';
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
                        borderRadius: BorderRadius.circular(18),
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
        Expanded(
          flex: 2,
          child: ListView(
            children: [
              if (isLoding)
                Container(
                  margin: EdgeInsets.only(
                    right: constraints.maxWidth * 0.12,
                    left: constraints.maxWidth * 0.12,
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    child: Center(
                      child: Text(
                        "Lodding...",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              if (!isLoding)
                Container(
                  margin: EdgeInsets.only(
                    right: constraints.maxWidth * 0.12,
                    left: constraints.maxWidth * 0.12,
                  ),
                  child: Consumer<WebsocketHelper>(
                    builder: (contex, wsHelper, _) {
                      return ElevatedButton(
                        onPressed: () => sumbit(context, wsHelper),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                        child: Center(
                          child: Text(
                            "Login",
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
          ),
        ),
      ],
    );
  }
}
