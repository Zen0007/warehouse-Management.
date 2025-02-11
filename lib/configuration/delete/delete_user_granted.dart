import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:werehouse_inventory/configuration/delete/controler_service_deleted.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class DeleteUserGranted extends StatefulWidget {
  const DeleteUserGranted({super.key});

  @override
  State<DeleteUserGranted> createState() => _AddNewAdminState();
}

class _AddNewAdminState extends State<DeleteUserGranted> {
  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();
  final textField = FocusNode();
  String name = '';
  bool isLoding = false;

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

      wsHelper.sendMessage(
        {
          "endpoint": "deleteUserGratend",
          "data": {
            "name": name,
          },
        },
      );

      await for (var data in wsHelper.streamControllerAll.stream) {
        if (data['endpoint'] == "FREEDATAGRATEND") {
          if (data.containsKey("warning")) {
            final warning = data['warning'];

            if (!context.mounted) return;
            messageFromServer(
              warning,
              false,
              Theme.of(context).colorScheme.error,
            );

            _fromKey.currentState!.reset();
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

            _fromKey.currentState!.reset();
            setState(
              () {
                isLoding = false;
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
      builder: (context) => AlertDialog(
        backgroundColor: color,
        title: Text(
          isMessage ? 'MESSAGE' : "WARNING",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          debugPrint("${constraints.maxWidth}");

          if (constraints.maxWidth < 800) {
            return mobile(context, constraints);
          } else {
            return desktop(context, constraints);
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

  Column desktop(BuildContext context, BoxConstraints constraints) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: EdgeInsets.only(
              right: constraints.maxWidth * 0.25,
              left: constraints.maxWidth * 0.25,
              top: constraints.maxWidth * 0.3,
            ),
            child: Form(
              key: _fromKey,
              child: TextFormField(
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
                      "Delete Use",
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
            top: constraints.maxWidth * 0.3,
          ),
          child: Form(
            key: _fromKey,
            child: TextFormField(
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
                      "Delete User",
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
