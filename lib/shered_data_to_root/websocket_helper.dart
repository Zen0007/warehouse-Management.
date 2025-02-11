import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:werehouse_inventory/data type/borrow_user.dart';
import 'package:werehouse_inventory/data%20type/index.dart';
import 'package:werehouse_inventory/data%20type/key_category_list.dart';

class WebsocketHelper with ChangeNotifier {
  WebsocketHelper(this.channel) {
    connect();
    grantedForReturnItem();
  }

  Stream? broadCastStream;
  Timer? _reconnectTimer;
  WebSocketChannel? channel;
  bool isConnected = false;
  final Duration _reconnectDelay = Duration(seconds: 5);
  final streamControllerAll = StreamController<Map>.broadcast();
  final streamCollectionAdmin = StreamController<List>.broadcast();
  final streamKeyResult = StreamController<List>.broadcast();
  final streamBorrow = StreamController<List>.broadcast();
  final streamPending = StreamController<List>.broadcast();
  final streamGranted = StreamController<List>.broadcast();

  final addNewData = StreamController<Map>.broadcast();
  final deleteCollection = StreamController<Map>.broadcast();
  final deleteItem = StreamController<Map>.broadcast();

  @override
  void dispose() {
    channel?.sink.close();
    streamControllerAll.close();
    streamCollectionAdmin.close();
    streamKeyResult.close();
    streamBorrow.close();
    streamPending.close();
    streamGranted.close();

    addNewData.close();
    deleteCollection.close();
    deleteItem.close();
    _reconnectTimer!.cancel();
    super.dispose();
  }

  static Map jsonDecodes(dynamic jsons) {
    return json.decode(jsons);
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
    notifyListeners();
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

  void connect() async {
    try {
      broadCastStream = channel?.stream.asBroadcastStream();
      broadCastStream?.listen(
        (message) async {
          // process code in another thread
          final streamData = await compute(jsonDecodes, message);

          switch (streamData['endpoint']) {
            case 'GETDATAALLCATEGORY':
              notifyListeners();
              streamCollectionAdmin.sink.add(streamData['message']);
              break;
            case "GETDATAALLKEYCATEGORY":
              notifyListeners();
              streamKeyResult.sink.add(streamData['message']);
              break;
            case "ADDNEWITEM":
              notifyListeners();
              addNewData.sink.add(streamData);
              break;
            case "DELETECATEGORY":
              notifyListeners();
              deleteCollection.sink.add(streamData);
              break;
            case "DELETEITEM":
              notifyListeners();
              deleteItem.sink.add(streamData);
              break;
            case "GETDATABORROW":
              notifyListeners();
              streamBorrow.sink.add(streamData['message']);
              break;
            case "GETDATAGRANTED":
              notifyListeners();
              streamGranted.sink.add(streamData['message']);
              break;
            case "GETDATAPENDING":
              notifyListeners();
              streamPending.sink.add(streamData['message']);
              break;
            default:
              notifyListeners();
              streamControllerAll.sink.add(streamData);
              break;
          }
          print("$streamData  connect");
        },
        onDone: () {
          print('connection close ');

          isConnected = false;
          reconnet();
          notifyListeners();
        },
        onError: (e) {
          print("$e  co");

          isConnected = false;
          reconnet();
          notifyListeners();
        },
      );

      isConnected = true;
      notifyListeners();
    } catch (e, s) {
      debugPrint("$e");
      debugPrint("$s");

      isConnected = false;
      reconnet();
      notifyListeners();
    }
  }

  //sent Frequent Request
  void getDataBorrow() {
    channel?.sink.add(json.encode({"endpoint": "getDataBorrow"}));
  }

  //sent once Request
  void getDataBorrowOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataBorrowOnce"}));
    notifyListeners();
  }

  //sent Frequent Request
  void getDataCategoryUser() {
    channel?.sink.add(json.encode({"endpoint": "getDataCollectionAvaileble"}));
  }

  //sent once Request
  void getDataCategoryUserOnce() {
    channel?.sink
        .add(json.encode({"endpoint": "getDataCollectionAvailebleOnce"}));
    notifyListeners();
  }

  //sent Frequent Request
  void getDataAllCollection() {
    channel?.sink.add(json.encode({"endpoint": "getDataAllCollection"}));
  }

  //sent once Request
  void getDataAllCollectionOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataAllCollectionOnce"}));
    notifyListeners();
  }

  //sent Frequent Request
  void getDataPending() {
    channel?.sink.add(json.encode({"endpoint": "getDataPending"}));
  }

  //sent once Request
  void getDataPendingOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataPendingOnce"}));
    notifyListeners();
  }

  //sent Frequent Request
  void getAllKeyCategory() {
    channel?.sink.add(json.encode({"endpoint": "getAllKeyCategory"}));
  }

  //sent once Request
  void getAllKeyCategoryOnce() {
    channel?.sink.add(json.encode({"endpoint": "getAllKeyCategoryOnce"}));
    notifyListeners();
  }

  //sent Frequent Request
  void getDataGranted() {
    channel?.sink.add(json.encode({"endpoint": "getDataGranted"}));
  }

  //sent once Request
  void getDataGrantedOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataGrantedOnce"}));
    notifyListeners();
  }

  void grantedForReturnItem() async {
    await for (var data in streamControllerAll.stream) {
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

  Future<Map> message() async {
    await Future.delayed(Duration(seconds: 10));
    return {"message": "respone"};
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

      await for (final status in streamControllerAll.stream) {
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

      await for (final status in streamControllerAll.stream) {
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

      await for (final status in streamControllerAll.stream) {
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

    await for (var map in streamControllerAll.stream) {
      if (map['endpoint'] == 'LOGIN') {
        data.addAll(map);
        notifyListeners();
        yield data;
      }
    }
  }

  Stream<Map> responseRegister() async* {
    Map data = {};

    await for (var map in streamControllerAll.stream) {
      if (map['endpoint'] == 'RIGISTER') {
        data.addAll(map);
        notifyListeners();
        yield data;
      }
    }
  }

  Stream<List<BorrowUser>> borrowUser() async* {
    await for (var data in streamControllerAll.stream) {
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
    await for (var data in streamControllerAll.stream) {
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

  List<BorrowUser> processPending(List data) {
    final List<BorrowUser> list = [];

    for (var i = 0; i < data.length; i++) {
      final Map dataMessage = data[i];
      for (var data in dataMessage.values) {
        if (data is Map) {
          final user = BorrowUser.from(data);
          list.add(user);
        }
      }
    }
    return list;
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
    await for (var index in streamControllerAll.stream) {
      if (index['endpoint'] == "GETDATACATEGORYAVAILEBLE") {
        if (index['message'].isEmpty) {
          yield [];
        }
        for (var i = 0; i < index['message'].length; i++) {
          if (index['message'][i][title] != null) {
            final List<Index> data = [];
            notifyListeners();
            yield data;
          }
        }
      }
    }
  }

  List<BorrowUser> processGranted(List data) {
    final List<BorrowUser> list = [];

    for (var i = 0; i < data.length; i++) {
      final Map dataMessage = data[i];

      for (var data in dataMessage.values) {
        if (data is Map) {
          final user = BorrowUser.from(data);
          list.add(user);
        }
      }
    }
    notifyListeners();
    return list;
  }

  List<Index>? processIndex(String title, List index) {
    final List<Index> data = [];

    for (var i = 0; i < index.length; i++) {
      if (index[i][title] != null) {
        for (var entry in index[i][title].entries) {
          final List<int> listInt =
              List<int>.from(entry.value['image'] as List);
          final Uint8List uint8list = Uint8List.fromList(listInt);

          final index =
              Index.fromJson(entry.value, entry.key, title, uint8list);
          data.add(index);
        }
        notifyListeners();
        return data;
      }
    }

    return data;
  }

  List<BorrowUser> processBorrow(List data) {
    List<BorrowUser> list = [];
    for (var i = 0; i < data.length; i++) {
      final Map dataMessage = data[i];
      for (var data in dataMessage.values) {
        if (data is Map) {
          final user = BorrowUser.from(data);
          list.add(user);
        }
      }
    }
    notifyListeners();
    return list;
  }

  List<KeyCategoryList> processKey(List data) {
    List<KeyCategoryList> key = [];
    for (var i = 0; i < data.length; i++) {
      final keyCategory = KeyCategoryList.fromJson(data[i]);
      key.add(keyCategory);
    }
    notifyListeners();
    return key;
  }
}
