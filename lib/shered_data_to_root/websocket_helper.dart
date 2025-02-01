import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:werehouse_inventory/data type/borrow_user.dart';
import 'package:werehouse_inventory/data%20type/index.dart';
import 'package:werehouse_inventory/data%20type/key_category_list.dart';

class WebsocketHelper with ChangeNotifier {
  WebSocketChannel? channel;
  WebsocketHelper(this.channel) {
    connect();
    grantedForReturnItem();
  }

  final StreamController<Map> streamController =
      StreamController<Map>.broadcast();
  Stream? broadCastStream;
  Timer? _reconnectTimer;
  bool isConnected = false;
  final Duration _reconnectDelay = Duration(seconds: 5);

  void getDataBorrow() {
    channel?.sink.add(json.encode({"endpoint": "getDataBorrow"}));
  }

  void getDataBorrowOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataBorrowOnce"}));
    notifyListeners();
  }

  void getDataCategoryUser() {
    channel?.sink.add(json.encode({"endpoint": "getDataCollectionAvaileble"}));
  }

  void getDataCategoryUserOnce() {
    channel?.sink
        .add(json.encode({"endpoint": "getDataCollectionAvailebleOnce"}));
    notifyListeners();
  }

  void getDataAllCollection() {
    channel?.sink.add(json.encode({"endpoint": "getDataAllCollection"}));
  }

  void getDataAllCollectionOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataAllCollectionOnce"}));
    notifyListeners();
  }

  void getDataPending() {
    channel?.sink.add(json.encode({"endpoint": "getDataPending"}));
  }

  void getDataPendingOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataPendingOnce"}));
    notifyListeners();
  }

  void getAllKeyCategory() {
    channel?.sink.add(json.encode({"endpoint": "getAllKeyCategory"}));
  }

  void getAllKeyCategoryOnce() {
    channel?.sink.add(json.encode({"endpoint": "getAllKeyCategoryOnce"}));
    notifyListeners();
  }

  void getDataGranted() {
    channel?.sink.add(json.encode({"endpoint": "getDataGranted"}));
  }

  void getDataGrantedOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataGrantedOnce"}));
    notifyListeners();
  }

  static Map jsonDecodes(dynamic jsons) {
    return json.decode(jsons);
  }

  void connect() async {
    try {
      broadCastStream = channel?.stream.asBroadcastStream();
      broadCastStream?.listen(
        (message) async {
          // process code in another thread
          final streamData = await compute(jsonDecodes, message);
          notifyListeners();

          streamController.sink.add(streamData);
        },
        onDone: () {
          print('connection close ');

          isConnected = false;
          reconnet();
        },
        onError: (e) {
          print(e);

          isConnected = false;
          reconnet();
        },
      );

      isConnected = true;
    } catch (e, s) {
      debugPrint("$e");
      debugPrint("$s");

      isConnected = false;
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
            notifyListeners();
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
            notifyListeners();
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

// for first request
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

  Stream<BorrowUser> userHasBorrow() async* {
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
          final keyData = await compute(processMessageKeyToIsolate, data);
          return keyData;
        }
      }
      return key;
    } catch (e, s) {
      print(e);
      print(s);
      throw Exception('$e');
    }
  }

  List<KeyCategoryList> processMessageKeyToIsolate(Map data) {
    List<KeyCategoryList> key = [];
    for (var i = 0; i < data['message'].length; i++) {
      final keyCategory = KeyCategoryList.fromJson(data['message'][i]);
      key.add(keyCategory);
    }

    notifyListeners();
    return key;
  }

  Stream<List<Index>> indexCategoryForUser(String title) async* {
    await for (var index in streamController.stream) {
      if (index['endpoint'] == "GETDATACATEGORYAVAILEBLE") {
        if (index['message'].isEmpty) {
          yield [];
        }
        for (var i = 0; i < index['message'].length; i++) {
          if (index['message'][i][title] != null) {
            final List<Index> data = await compute(
              processMessageToIsolate,
              {
                'message': index['message'][i][title],
                "title": title,
              },
            );
            notifyListeners();
            yield data;
          }
        }
      }
    }
  }

  Stream<List<Index>> indexCategoryForAdmin(String title) async* {
    await for (var index in streamController.stream) {
      if (index['endpoint'] == "GETDATAALLCATEGORY") {
        for (var i = 0; i < index['message'].length; i++) {
          if (index['message'][i][title] != null) {
            final List<Index> data = await compute(
              processMessageToIsolate,
              {
                'message': index['message'][i][title],
                "title": title,
              },
            );

            yield data;
            notifyListeners();
          }
        }
      }
    }
    notifyListeners();
  }

  static List<Index> processMessageKeyInIsolate(List message) {
    final title = message[0];
    final index = message[1];
    final List<Index> resultData = [];

    if (index['message'].isEmpty) {
      return resultData;
    }
    for (var i = 0; i < index['message'].length; i++) {
      if (index['message'][i][title] != null) {
        for (var entry in index['message'][i][title].entries) {
          final List<int> listInt =
              List<int>.from(entry.value['image'] as List);

          final Uint8List uint8list = Uint8List.fromList(listInt);

          final index =
              Index.fromJson(entry.value, entry.key, title, uint8list);
          resultData.add(index);
        }

        return resultData;
      }
    }

    return resultData;
  }

  List<Index> processMessageToIsolate(Map map) {
    final dynamic index = map['message'];
    final String title = map['title'];
    final List<Index> data = [];
    for (var entry in index.entries) {
      final List<int> listInt = List<int>.from(entry.value['image'] as List);
      final Uint8List uint8list = Uint8List.fromList(listInt);

      final index = Index.fromJson(entry.value, entry.key, title, uint8list);
      data.add(index);
    }
    return data;
  }

  Uint8List imageProcess(dynamic image) {
    final List<int> listInt = List<int>.from(image as List);
    final Uint8List uint8list = Uint8List.fromList(listInt);

    return uint8list;
  }

  @override
  void dispose() {
    channel?.sink.close();
    streamController.close();
    _reconnectTimer!.cancel();
    super.dispose();
  }
}
