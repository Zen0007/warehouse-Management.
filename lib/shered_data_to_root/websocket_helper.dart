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
  final stramCollectionAvaileble = StreamController<List>.broadcast();
  final streamKeyResult = StreamController<List>.broadcast();
  final streamBorrow = StreamController<List>.broadcast();
  final streamPending = StreamController<List>.broadcast();
  final streamGranted = StreamController<List>.broadcast();
  final streamUserHasBorrow = StreamController<Map>.broadcast();

  final addNewData = StreamController<Map>.broadcast();
  final deleteCollection = StreamController<Map>.broadcast();
  final deleteItem = StreamController<Map>.broadcast();
  final userApproveReturn = StreamController<Map>.broadcast();
  final verifikasiHasLogin = StreamController<Map>.broadcast();
  final checkUserHasBorrows = StreamController<String>.broadcast();

  @override
  void dispose() {
    channel?.sink.close();
    streamControllerAll.close();
    streamCollectionAdmin.close();
    streamKeyResult.close();
    streamBorrow.close();
    streamPending.close();
    streamGranted.close();
    streamUserHasBorrow.close();

    addNewData.close();
    deleteCollection.close();
    deleteItem.close();
    userApproveReturn.close();
    verifikasiHasLogin.close();
    checkUserHasBorrows.close();
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
            case "GRANTED":
              notifyListeners();
              userApproveReturn.sink.add(streamData);
              break;
            case "VERIFIKASI":
              notifyListeners();
              verifikasiHasLogin.sink.add(streamData);
              break;
            case "GETDATACATEGORYAVAILEBLE":
              notifyListeners();
              stramCollectionAvaileble.sink.add(streamData['message']);
              break;
            case "HASBORROW":
              notifyListeners();
              streamUserHasBorrow.sink.add(streamData['message']);
              break;
            case "CHECKUSER":
              checkUserHasBorrows.sink.add(streamData['message']);
              notifyListeners();
              print(streamData);
              break;
            default:
              notifyListeners();
              streamControllerAll.sink.add(streamData);
              break;
          }
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

  void checkUserHasBorrow() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final getToken = prefs.getString('hasBorrow');
    final now = DateTime.now();
    final lastRequest = DateTime.parse(
      prefs.getString('RequestUser') ??
          now.subtract(Duration(seconds: 2)).toIso8601String(),
    );
    if (now.difference(lastRequest).inSeconds >= 2) {
      print("tokenUser $getToken");
      if (getToken != null) {
        channel?.sink.add(
          json.encode(
            {
              "endpoint": "checkUserBorrow",
              "data": {
                "name": getToken,
              }
            },
          ),
        );
      }
      prefs.setString('RequestUser', now.toIso8601String());
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
            now.subtract(Duration(minutes: 10)).toIso8601String(),
      );

      // debugPrint("$getToken token wsHelper");
      // debugPrint("${prefs.getString('lastRequest')} exp wsHelper");

      if (now.difference(lastRequest).inMinutes >= 10) {
        if (getToken != null) {
          channel?.sink.add(json.encode(
            {
              "endpoint": "verifikasi",
              "data": {
                "token": getToken,
              }
            },
          ));
        }
        prefs.setString('lastRequest', now.toIso8601String());
      }

      await for (final status in streamControllerAll.stream) {
        if (status['endpoint'] == "VERIFIKASI") {
          yield status['status'];
        }
      }
    } catch (e) {
      debugPrint("$e error in verifikasi");
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

  @Deprecated("this code is not proper ")
  Stream<BorrowUser> userHasBorrows() async* {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final getToken = prefs.getString('hasBorrow');
    print("$getToken user name");

    try {
      await for (final status in streamControllerAll.stream) {
        if (status['endpoint'] == "HASBORROW") {
          for (var data in status['message'].values) {
            if (data is Map) {
              final List<int> listInt =
                  List<int>.from(data['imageSelfie'] as List);
              final Uint8List uint8list = Uint8List.fromList(listInt);

              final user = BorrowUser.from(data, uint8list);
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

  void sendRequestUserHasBorrow() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final getToken = prefs.getString('hasBorrow');
    channel?.sink.add(json.encode(
      {
        "endpoint": "hasBorrow",
        "data": {
          "name": getToken ?? '',
        }
      },
    ));
  }

  BorrowUser? processUserHasBorrow(Map status) {
    BorrowUser? user;
    for (var data in status.values) {
      if (data is Map) {
        final List<int> listInt = List<int>.from(data['imageSelfie'] as List);
        final Uint8List uint8list = Uint8List.fromList(listInt);

        user = BorrowUser.from(data, uint8list);
        return user;
      }
    }
    return user;
  }

  List<BorrowUser> processPending(List data) {
    final List<BorrowUser> list = [];

    for (var i = 0; i < data.length; i++) {
      final Map dataMessage = data[i];
      for (var data in dataMessage.values) {
        if (data is Map) {
          final List<int> listInt = List<int>.from(data['imageSelfie'] as List);
          final Uint8List uint8list = Uint8List.fromList(listInt);

          final user = BorrowUser.from(data, uint8list);
          list.add(user);
        }
      }
    }
    return list;
  }

  List<BorrowUser> processGranted(List data) {
    final List<BorrowUser> list = [];

    for (var i = 0; i < data.length; i++) {
      final Map dataMessage = data[i];

      for (var data in dataMessage.values) {
        if (data is Map) {
          final List<int> listInt = List<int>.from(data['imageSelfie'] as List);
          final Uint8List uint8list = Uint8List.fromList(listInt);

          final user = BorrowUser.from(data, uint8list);
          list.add(user);
        }
      }
    }

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

        return data;
      }
    }

    return data;
  }

  List<Index> processForUser(List index, String title) {
    final List<Index> data = [];
    for (var i = 0; i < index.length; i++) {
      if (index[i][title] != null) {
        for (var entry in index[i][title].entries) {
          final listInt = List<int>.from(entry.value['image'] as List);
          final uint8list = Uint8List.fromList(listInt);
          final index =
              Index.fromJson(entry.value, entry.key, title, uint8list);
          data.add(index);
        }

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
          final List<int> listInt = List<int>.from(data['imageSelfie'] as List);
          final Uint8List uint8list = Uint8List.fromList(listInt);

          final user = BorrowUser.from(data, uint8list);
          list.add(user);
        }
      }
    }
    return list;
  }

  List<KeyCategoryList> processKey(List data) {
    List<KeyCategoryList> key = [];
    for (var i = 0; i < data.length; i++) {
      final keyCategory = KeyCategoryList.fromJson(data[i]);
      key.add(keyCategory);
    }

    return key;
  }
}
