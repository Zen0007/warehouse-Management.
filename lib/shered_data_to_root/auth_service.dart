import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:werehouse_inventory/data%20type/borrow_user.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService with ChangeNotifier {
  AuthService(this.wsHelper);
  final WebsocketHelper wsHelper;

  final storage = FlutterSecureStorage();

  Stream<String?> verifikasiLogin() async* {
    final token = await storage.read(key: 'token');
    yield token;
  }

  Stream<BorrowUser?> dataLocalUserHasBorrow() async* {
    final localData = await storage.read(key: 'dataItemBorrowUser');
    if (localData == null) {
      yield null;
    }

    final Map listItemUser = json.decode(localData!);

    final List<int> listInt =
        List<int>.from(listItemUser['imageSelfie'] as List);
    final Uint8List uint8list = Uint8List.fromList(listInt);
    print(listItemUser);
    yield BorrowUser.from(listItemUser, uint8list);
  }

  Stream<String?> userHasBorrow() async* {
    final nameUserHasBorrow = await storage.read(key: "nameUserHasBorrow");
    yield nameUserHasBorrow;
  }

  void chekVerifikasi() async {
    try {
      final getToken = await storage.read(key: 'token');
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
    await for (final status in wsHelper.verifikasiHasLogin.stream) {
      int count = 1;
      if (status['status'] == "NOT-VERIFIKASI") {
        notifyListeners();
        final getToken = await storage.read(key: 'token');
        await storage.delete(key: 'token');
        print("affter delete $getToken");
        count++;
        print("count $count");
        return;
      }
    }
  }

  void getNewStatusUser() async {
    final nameUserHasBorrow = await storage.read(key: "nameUserHasBorrow");
    Timer? timer;
    timer = Timer.periodic(
      Duration(seconds: 10),
      (_) {
        wsHelper.sendMessage(
          {
            "endpoint": "hasBorrow",
            "data": {
              "name": nameUserHasBorrow ?? '',
            }
          },
        );
        timer?.cancel();
      },
    );
  }

  @override
  void dispose() {
    wsHelper.dispose();
    super.dispose();
  }
}
