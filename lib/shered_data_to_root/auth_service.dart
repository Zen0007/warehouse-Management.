import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:werehouse_inventory/shered_data_to_root/websocket_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService with ChangeNotifier {
  AuthService(this.wsHelper);
  final WebsocketHelper wsHelper;
  Timer? timer;
  final storage = FlutterSecureStorage();

  Stream<String?> verifikasiLogin() async* {
    final token = await storage.read(key: 'token');
    yield token;
  }

  void chekVerifikasi() async {
    try {
      final getToken = await storage.read(key: 'token');

      if (getToken != null) {
        Timer.periodic(
          Duration(seconds: 10),
          (_) {
            wsHelper.channel?.sink.add(json.encode(
              {
                "endpoint": "verifikasi",
                "data": {
                  "token": getToken,
                }
              },
            ));

            print("token get $getToken");
            return;
          },
        );

        // To cancel the subscription later:
      }
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
}
