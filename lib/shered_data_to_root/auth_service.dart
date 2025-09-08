import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:werehouse_inventory/data%20type/borrow_user.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';

class AuthService with ChangeNotifier {
  AuthService(this.wsHelper);
  final WebsocketHelper wsHelper;

  Stream<String?> verifikasiLogin() async* {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    yield token;
  }

  Stream<BorrowUser?> dataLocalUserHasBorrow() async* {
    final prefs = await SharedPreferences.getInstance();
    final localData = prefs.getString('dataItemBorrowUser');
    if (localData == null) {
      yield null;
    }

    final Map listItemUser = json.decode(localData!);

    final List<int> listInt =
        List<int>.from(listItemUser['imageSelfie'] as List);
    final Uint8List uint8list = Uint8List.fromList(listInt);

    yield BorrowUser.from(listItemUser, uint8list);
  }

  Stream<String?> userHasBorrow() async* {
    final prefs = await SharedPreferences.getInstance();
    final nameUserHasBorrow = prefs.getString("nameUserHasBorrow");
    yield nameUserHasBorrow;
  }

  void chekVerifikasi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final getToken = prefs.getString('token');
      Timer? timer;
      timer = Timer.periodic(
        Duration(seconds: 10),
        (_) {
          if (getToken != null) {
            wsHelper.sendMessage(
              {
                "endpoint": "verifikasi",
                "data": {
                  "token": getToken,
                }
              },
            );

            timer?.cancel();
          }
        },
      );
    } catch (e) {
      debugPrint("$e error in verifikasi");
    }
  }

  void removeTokenIfExp() async {
    final prefs = await SharedPreferences.getInstance();
    await for (final status in wsHelper.verifikasiHasLogin.stream) {
      int count = 1;
      if (status['status'] == "NOT-VERIFIKASI") {
        notifyListeners();
        final getToken = prefs.getString('token');
        prefs.remove('token');
        print("affter delete $getToken");
        count++;
        print("count $count");
        return;
      }
    }
  }

  // void getNewStatusUser() async {
  //   final nameUserHasBorrow = await storage.read(key: "nameUserHasBorrow");
  //   Timer? timer;
  //   timer = Timer.periodic(
  //     Duration(seconds: 10),
  //     (_) {
  //       wsHelper.sendMessage(
  //         {
  //           "endpoint": "hasBorrow",
  //           "data": {
  //             "name": nameUserHasBorrow ?? '',
  //           }
  //         },
  //       );
  //       timer?.cancel();
  //     },
  //   );
  // }

  @override
  void dispose() {
    wsHelper.dispose();
    super.dispose();
  }
}
