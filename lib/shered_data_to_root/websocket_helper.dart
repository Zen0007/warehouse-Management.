import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:werehouse_inventory/data type/borrow_user.dart';
import 'package:werehouse_inventory/data%20type/index.dart';
import 'package:werehouse_inventory/data%20type/key_category_list.dart';

class WebsocketHelper with ChangeNotifier {
  WebsocketHelper(this.channel) {
    connect();
  }

  WebSocketChannel? channel;
  final StreamController<Map> streamController =
      StreamController<Map>.broadcast();
  Stream? broadCastStream;
  Timer? _reconnectTimer;
  bool isConnected = false;
  final Duration _reconnectDelay = Duration(seconds: 5);

  void getDataBorrow() {
    channel?.sink.add(json.encode({"endpoint": "getDataBorrow"}));
    notifyListeners();
  }

  void getDataBorrowOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataBorrowOnce"}));
    notifyListeners();
  }

  void getDataCategoryUser() {
    channel?.sink.add(json.encode({"endpoint": "getDataCollectionAvaileble"}));
    notifyListeners();
  }

  void getDataCategoryUserOnce() {
    channel?.sink
        .add(json.encode({"endpoint": "getDataCollectionAvailebleOnce"}));
    notifyListeners();
  }

  void getDataAllCollection() {
    channel?.sink.add(json.encode({"endpoint": "getDataAllCollection"}));
    notifyListeners();
  }

  void getDataAllCollectionOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataAllCollectionOnce"}));
    notifyListeners();
  }

  void getDataPending() {
    channel?.sink.add(json.encode({"endpoint": "getDataPending"}));
    notifyListeners();
  }

  void getDataPendingOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataPendingOnce"}));
    notifyListeners();
  }

  void getAllKeyCategory() {
    channel?.sink.add(json.encode({"endpoint": "getAllKeyCategory"}));
    notifyListeners();
  }

  void getDataGranted() {
    channel?.sink.add(json.encode({"endpoint": "getDataGranted"}));
    notifyListeners();
  }

  void getDataGrantedOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataGrantedOnce"}));
    notifyListeners();
  }

  void userHasBorrowsOnce() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final getToken = prefs.getString('hasBorrow');
    print("$getToken user name");

    channel?.sink.add(json.encode(
      {
        "endpoint": "hasBorrowOnce",
        "data": {
          "name": getToken ?? '',
        }
      },
    ));
  }

  void connect() async {
    try {
      broadCastStream = channel?.stream.asBroadcastStream();
      notifyListeners();
      broadCastStream?.listen(
        (message) {
          final streamData = json.decode(message);
          notifyListeners();

          streamController.sink.add(streamData);
        },
        onDone: () {
          print('connection close ');

          isConnected = false;
          notifyListeners();
          reconnet();
        },
        onError: (e) {
          print(e);

          isConnected = false;
          notifyListeners();
          reconnet();
        },
      );

      isConnected = true;
      notifyListeners();
    } catch (e, s) {
      debugPrint("$e");
      debugPrint("$s");

      isConnected = false;
      notifyListeners();
      reconnet();
    }
  }

  void closeWebSocket() {
    if (channel != null) {
      channel?.sink.close();
      channel = null; // Clear the WebSocketChannel reference
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      broadCastStream = null;
      isConnected = false;
      notifyListeners();
    }
  }

  void reconnet() async {
    closeWebSocket();
    try {
      if (_reconnectTimer == null || !_reconnectTimer!.isActive) {
        _reconnectTimer = Timer(
          _reconnectDelay,
          () {
            print("attempting to reconnect .....");
            connect();
          },
        );
      }
    } catch (e) {
      if (_reconnectTimer == null || !_reconnectTimer!.isActive) {
        _reconnectTimer = Timer(
          _reconnectDelay,
          () {
            print("attempting to reconnect .....");
            connect();
          },
        );
      }
      print(e);
    }
  }

  void grantedForReturnItem() async {
    await for (var data in streamController.stream) {
      if (data['endpoint'] == "GRANTED") {
        if (data.containsKey('message')) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('hasBorrow');
          notifyListeners();
          return;
        }
      }
    }
  }

  void testDeleteUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('hasBorrow');
    return;
  }

  void sendMessage(Map<String, dynamic> message) {
    channel?.sink.add(
      json.encode(message),
    );
    notifyListeners();
  }

  void sendRequestReturnItem() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final getToken = prefs.getString('hasBorrow');
    channel?.sink.add(
      json.encode(
        {
          'endpoint': "waitPermision",
          'data': {
            "name": getToken ?? "",
          }
        },
      ),
    );
  }

  Stream<String> verifikasi() async* {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final getToken = prefs.getString('token');

    try {
      DateTime now = DateTime.now();
      DateTime lastRequest = DateTime.parse(
        prefs.getString('lastRequest') ??
            now.subtract(Duration(hours: 1)).toIso8601String(),
      );

      // debugPrint("$getToken token wsHelper");
      // debugPrint("${prefs.getString('lastRequest')} exp wsHelper");

      if (now.difference(lastRequest).inHours >= 1) {
        channel?.sink.add(json.encode(
          {
            "endpoint": "verifikasi",
            "data": {
              "token": getToken,
            }
          },
        ));

        prefs.setString('lastRequest', now.toIso8601String());
      }

      DateTime nextRequest = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour + 1,
      );
      Duration delayed = nextRequest.difference(now);
      Timer(
        delayed,
        () => channel?.sink.add(json.encode(
          {
            "endpoint": "verifikasi",
            "data": {
              "token": getToken,
            }
          },
        )),
      );

      await for (final status in streamController.stream) {
        if (status['endpoint'] == "VERIFIKASI") {
          notifyListeners();
          yield status['status'];
        }
      }
    } catch (e) {
      debugPrint("$e error in verifikasi");
    }
  }

  Stream<String> checkUserHasBorrow() async* {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final getToken = prefs.getString('hasBorrow');
      Future.delayed(Duration(seconds: 3), () {
        channel?.sink.add(json.encode(
          {
            "endpoint": "checkUserBorrow",
            "data": {
              "name": getToken ?? '',
            }
          },
        ));
      });

      await for (final status in streamController.stream) {
        if (status['endpoint'] == "CHECKUSER") {
          final String dataUser = status['message'];
          notifyListeners();
          yield dataUser;
        }
      }
    } catch (e, s) {
      print(e);
      debugPrint("$s strackTrace");
    }
  }

  Stream<BorrowUser> userHasBorrows() async* {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final getToken = prefs.getString('hasBorrow');
    print("$getToken user name");

    try {
      channel?.sink.add(json.encode(
        {
          "endpoint": "hasBorrow",
          "data": {
            "name": getToken ?? '',
          }
        },
      ));

      await for (final status in streamController.stream) {
        if (status['endpoint'] == "HASBORROW") {
          for (var data in status['message'].values) {
            if (data is Map) {
              final user = BorrowUser.from(data);
              notifyListeners();
              yield user;
            }
          }
        }
      }
    } catch (e, s) {
      print(e);
      debugPrint("$s strackTrace");
    }
  }

  Stream<Map> responseLogin() async* {
    Map data = {};

    await for (var map in streamController.stream) {
      if (map['endpoint'] == 'LOGIN') {
        data.addAll(map);
        notifyListeners();
        yield data;
      }
    }
  }

  Stream<Map> responseRegister() async* {
    Map data = {};

    await for (var map in streamController.stream) {
      if (map['endpoint'] == 'RIGISTER') {
        data.addAll(map);
        notifyListeners();
        yield data;
      }
    }
  }

  Stream<List<BorrowUser>> borrowUser() async* {
    await for (var data in streamController.stream) {
      if (data['endpoint'] == 'GETDATABORROW') {
        final List<BorrowUser> list = [];

        if (data['message'].isEmpty) {
          yield [];
        }

        for (var i = 0; i < data['message'].length; i++) {
          final Map dataMessage = data['message'][i];
          for (var data in dataMessage.values) {
            if (data is Map) {
              final user = BorrowUser.from(data);
              list.add(user);
            }
          }
        }
        notifyListeners();
        yield list;
      }
    }
  }

  Stream<List<BorrowUser>> pendingData() async* {
    await for (var data in streamController.stream) {
      if (data['endpoint'] == 'GETDATAPENDING') {
        final List<BorrowUser> list = [];

        if (data['message'].isEmpty) {
          yield [];
        }

        for (var i = 0; i < data['message'].length; i++) {
          final Map dataMessage = data['message'][i];
          for (var data in dataMessage.values) {
            if (data is Map) {
              final user = BorrowUser.from(data);
              list.add(user);
            }
          }
        }
        notifyListeners();
        yield list;
      }
    }
  }

  Stream<List<BorrowUser>> userHasReturnItems() async* {
    await for (var data in streamController.stream) {
      if (data['endpoint'] == 'GETDATAGRANTED') {
        final List<BorrowUser> list = [];

        if (data['message'].isEmpty) {
          yield [];
        }
        for (var i = 0; i < data['message'].length; i++) {
          final Map dataMessage = data['message'][i];

          for (var data in dataMessage.values) {
            if (data is Map) {
              final user = BorrowUser.from(data);
              list.add(user);
            }
          }
        }
        notifyListeners();
        yield list;
      }
    }
  }

  Future<List<KeyCategoryList>> keyCategory() async {
    try {
      List<KeyCategoryList> key = [];

      await for (var data in streamController.stream) {
        if (data['endpoint'] == "GETDATAALLKEYCATEGORY") {
          for (var i = 0; i < data['message'].length; i++) {
            print("${streamController.stream} stream");
            print('${data} data stream ');
            final keyCategory = KeyCategoryList.fromJson(data['message'][i]);
            key.add(keyCategory);
          }
          notifyListeners();
          return key;
        }
      }
      return [];
    } catch (e, s) {
      print(e);
      print(s);
      return [];
    }
  }

  Stream<List<Index>> indexCategoryForUser(String title) async* {
    List<Index> data = [];

    await for (var index in streamController.stream) {
      if (index['endpoint'] == "GETDATACATEGORYAVAILEBLE") {
        if (index['message'].isEmpty) {
          yield [];
        }

        for (var i = 0; i < index['message'].length; i++) {
          if (index['message'][i][title] != null) {
            for (var entry in index['message'][i][title].entries) {
              final index = Index.fromJson(entry.value, entry.key, title);
              data.add(index);
            }
          }
        }
        notifyListeners();
        yield data;
      }
    }
  }

  Stream<List<Index>> indexCategoryForAdmin(String title) async* {
    final List<Index> data = [];

    await for (var index in streamController.stream) {
      if (index['endpoint'] == "GETDATAALLCATEGORY") {
        if (index['message'].isEmpty) {
          yield [];
        }

        for (var i = 0; i < index['message'].length; i++) {
          if (index['message'][i][title] != null) {
            for (var entry in index['message'][i][title].entries) {
              final index = Index.fromJson(entry.value, entry.key, title);
              data.add(index);
            }
          }
        }
        notifyListeners();
        yield data;
      }
    }
  }

  void freeGrantedIfPastOneYear() {}

  @override
  void dispose() {
    channel?.sink.close();
    super.dispose();
  }
}
