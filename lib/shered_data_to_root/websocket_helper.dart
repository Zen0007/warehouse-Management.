import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:werehouse_inventory/data%20type/index.dart';
import 'package:werehouse_inventory/data type/borrow_user.dart';

import 'package:werehouse_inventory/data%20type/key_category_list.dart';

class WebsocketHelper with ChangeNotifier {
  WebsocketHelper(this.channel) {
    connect();
  }

  Stream? broadCastStream;
  Timer? _reconnectTimer;
  WebSocketChannel? channel;
  bool isConnected = false;
  final storage = FlutterSecureStorage();

  final Duration _reconnectDelay = Duration(seconds: 5);
  final streamControllerAll = StreamController<Map>.broadcast();
  final streamCollectionAdmin = StreamController<List>.broadcast();
  final streamCollectionAvaileble = StreamController<List>.broadcast();
  final streamKeyResult = StreamController<List>.broadcast();
  final streamBorrow = StreamController<List>.broadcast();
  final streamPending = StreamController<List>.broadcast();
  final streamGranted = StreamController<List>.broadcast();

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
    streamCollectionAvaileble.close();
    streamKeyResult.close();
    streamBorrow.close();
    streamPending.close();
    streamGranted.close();

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

  void processConnectionServer(Stream? connections) async {
    connections?.listen(
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
            streamCollectionAvaileble.sink.add(streamData['message']);
            break;
          case "HASBORROW":
            final String? nameUser = await storage.read(
              key: "nameUserHasBorrow",
            );
            if (streamData['message'].containsKey(nameUser)) {
              storage.write(
                key: 'dataItemBorrowUser',
                value: streamData['message'][nameUser],
              );
            }
            notifyListeners();
            break;
          case "CHECKUSER":
            checkUserHasBorrows.sink.add(streamData['message']);
            notifyListeners();
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
  }

  void connect() async {
    try {
      broadCastStream = channel?.stream.asBroadcastStream();

      await compute(
        processConnectionServer,
        broadCastStream,
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

  //sent once Request
  void getDataBorrowOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataBorrowOnce"}));
    notifyListeners();
  }

  //sent once Request
  void getDataCategoryUserOnce() {
    channel?.sink
        .add(json.encode({"endpoint": "getDataCollectionAvailebleOnce"}));
    notifyListeners();
  }

  //sent once Request
  void getDataAllCollectionOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataAllCollectionOnce"}));
    notifyListeners();
  }

  //sent once Request
  void getDataPendingOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataPendingOnce"}));
    notifyListeners();
  }

  //sent once Request
  void getAllKeyCategoryOnce() {
    channel?.sink.add(json.encode({"endpoint": "getAllKeyCategoryOnce"}));
    notifyListeners();
  }

  //sent once Request
  void getDataGrantedOnce() {
    channel?.sink.add(json.encode({"endpoint": "getDataGrantedOnce"}));
    notifyListeners();
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

  @Deprecated("this code is not proper so must to change ")
  Stream<BorrowUser> userHasBorrowss() async* {
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
