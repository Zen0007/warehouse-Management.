import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:werehouse_inventory/screeen/user_stuff/user_has_borrow.dart';
import 'package:werehouse_inventory/shered_data_to_root/shared_preferences.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class FormForUser extends StatefulWidget {
  const FormForUser({super.key});

  @override
  State<FormForUser> createState() => _FormForUserState();
}

class _FormForUserState extends State<FormForUser> {
  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();
  final textField = FocusNode();
  String name = '';
  String kelas = '';
  String nisn = '';
  String nameGuru = '';
  bool isLoding = false;
  bool obscureText = true;
  Uint8List? image;
  final pickerImageFromGalery = ImagePicker();

  void toggleObscure() {
    setState(() {
      obscureText = !obscureText;
      textField.canRequestFocus = false;
    });
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

  void sumbit(BuildContext context, WebsocketHelper wsHelper) async {
    try {
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

      setState(
        () {
          isLoding = true;
        },
      );

      if (image == null) {
        alertIfImageNull("wajib melampirkan selfie");

        setState(
          () {
            isLoding = false;
          },
        );
        return;
      }
      final listChoiceUser =
          await StoredUserChoice().getListFromSharedPreferences();
      debugPrint("$listChoiceUser form user---------------------------");
      wsHelper.sendMessage(
        {
          "endpoint": "borrowing",
          "data": {
            "name": name,
            "class": kelas,
            "nisn": nisn,
            "teacher": nameGuru,
            "time": "${DateTime.now()}",
            "imageSelfie": image,
            "items": listChoiceUser,
          },
        },
      );

      await for (var data in wsHelper.streamControllerAll.stream) {
        if (data['endpoint'] == 'BORROWING') {
          if (data.containsKey("warning")) {
            final warning = data['warning'];

            if (!context.mounted) return;
            alertDialog(warning);

            Future.delayed(
              Duration(seconds: 1),
              () {
                setState(
                  () {
                    isLoding = false;
                  },
                );
              },
            );
            return;
          } else if (data.containsKey('message')) {
            wsHelper.sendMessage(
              {
                "endpoint": "checkUserBorrow",
                "data": {
                  "name": name,
                }
              },
            ); // get data user

            final prefs = await SharedPreferences.getInstance();

            prefs.setString('hasBorrow', name);
            prefs.remove("choice");

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
            if (!context.mounted) return;
            messages(wsHelper);
          }
        }
      }
    } catch (e, s) {
      debugPrint("$e form user");
      debugPrint("$s from user");
    }
  }

  Future<dynamic> messages(WebsocketHelper wsHelper) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(
          'MESSAGE',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          "Barang yang anda pinjam sudah dapat di ambil",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return UserHasBorrows();
                  },
                ),
              );
              wsHelper.userHasBorrowsOnce(); //send request to database once
            },
            child: Text(
              "Yes",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> alertDialog(warning) {
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

  void _pickerImageGalery() async {
    final XFile? pickedImage = await pickerImageFromGalery.pickImage(
      source: ImageSource.camera,
      imageQuality: 20,
    );
    if (pickedImage != null) {
      final imagePicker = await pickedImage.readAsBytes();
      setState(
        () {
          image = imagePicker;
        },
      );
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Center(
            child: Text(
              "No file selected",
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
  }

  void clearImage() {
    setState(() {
      image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(builder: (context, constraints) {
        debugPrint("${constraints.maxWidth}");

        if (constraints.maxWidth < 700) {
          return mobile(context, constraints);
        } else {
          return desktop(context, constraints);
        }
      }),
    );
  }

  ListView desktop(BuildContext context, BoxConstraints constraints) {
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
              child: Center(
                child: Text(
                  'add image',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
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
            right: constraints.maxWidth * 0.2,
            left: constraints.maxWidth * 0.2,
            top: constraints.maxWidth * 0.05,
          ),
          child: Form(
            key: _fromKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    hintText: " nama",
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
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                  onSaved: (newValue) => name = newValue ?? "",
                ), // sizeBox
                SizedBox(
                  height: constraints.maxWidth * 0.03,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: " kelas",
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
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                  onSaved: (newValue) => kelas = newValue ?? "",
                ), // sizeBox
                SizedBox(
                  height: constraints.maxWidth * 0.03,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: " nisn",
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
                  keyboardType: TextInputType.number,
                  autocorrect: true,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                  onSaved: (newValue) => nisn = newValue ?? "",
                ), // sizeBox
                SizedBox(
                  height: constraints.maxWidth * 0.03,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: " nama guru",
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
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                  onSaved: (newValue) => nameGuru = newValue ?? "",
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
              top: constraints.maxWidth * 0.08,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: EdgeInsets.only(
                    top: constraints.maxWidth * 0.08,
                    bottom: constraints.maxWidth * 0.1),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Center(
                    child: Text(
                      "cencel",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                    top: constraints.maxWidth * 0.08,
                    bottom: constraints.maxWidth * 0.1),
                child: Consumer<WebsocketHelper>(
                  builder: (contex, wsHelper, child) {
                    return ElevatedButton(
                      onPressed: () {
                        sumbit(context, wsHelper);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      child: Center(
                        child: Text(
                          "sumbit",
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
      ],
    );
  }

  ListView mobile(BuildContext context, BoxConstraints constraints) {
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
              child: Center(
                child: Text(
                  'add image',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
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
            right: constraints.maxWidth * 0.1,
            left: constraints.maxWidth * 0.1,
            top: constraints.maxWidth * 0.05,
            bottom: constraints.maxWidth * 0.005,
          ),
          child: Form(
            key: _fromKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    hintText: " nama",
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
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                  onSaved: (newValue) => name = newValue ?? "",
                ),
                // sizeBox
                SizedBox(
                  height: constraints.maxWidth * 0.03,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: " kelas",
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
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                  onSaved: (newValue) => kelas = newValue ?? "",
                ),
                SizedBox(
                  height: constraints.maxWidth * 0.03,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: " nisn",
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
                  keyboardType: TextInputType.number,
                  autocorrect: true,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                  onSaved: (newValue) => nisn = newValue ?? "",
                ),
                SizedBox(
                  height: constraints.maxWidth * 0.03,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: " nama guru",
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
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                  onSaved: (newValue) => nameGuru = newValue ?? "",
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: constraints.maxWidth * 0.25,
                  bottom: constraints.maxWidth * 0.05,
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Center(
                    child: Text(
                      "cencel",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: constraints.maxWidth * 0.25,
                  bottom: constraints.maxWidth * 0.05,
                ),
                child: Consumer<WebsocketHelper>(
                  builder: (contex, wsHelper, child) {
                    return ElevatedButton(
                      onPressed: () {
                        sumbit(context, wsHelper);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      child: Center(
                        child: Text(
                          "sumbit",
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
      ],
    );
  }
}
