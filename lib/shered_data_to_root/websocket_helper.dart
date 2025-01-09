import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:werehouse_inventory/dummy_data/decode.dart';

class WebsocketHelper with ChangeNotifier {
  final WebSocketChannel _channel =
      WebSocketChannel.connect(Uri.parse('ws://127.0.0.1:8080/ws'));
  final StreamController<Map> streamController =
      StreamController<Map>.broadcast();

  WebsocketHelper() {
    connect();
  }

  void getDataBorrow() {
    _channel.sink.add(json.encode({"endpoint": "getDataBorrow"}));
  }

  void getDataCategoryUser() {
    _channel.sink.add(json.encode({"endpoint": "getDataCollectionAvaileble"}));
  }

  void getDataAllCollection() {
    _channel.sink.add(json.encode({"endpoint": "getDataAllCollection"}));
  }

  void getDataPending() {
    _channel.sink.add(json.encode({"endpoint": "getDataPending"}));
  }

  void getAllKeyCategory() {
    _channel.sink.add(json.encode({"endpoint": "getAllKeyCategory"}));
  }

  void getDataGranted() {
    _channel.sink.add(json.encode({"endpoint": "getDataGranted"}));
  }

  void connect() async {
    _channel.stream.listen(
      (message) {
        final streamData = json.decode(message);
        notifyListeners();

        streamController.sink.add(streamData);
        print(streamData);
      },
      onDone: () {
        print("losset connect web socket");
        reconnet();
      },
      onError: (e) {
        print(e);
        reconnet();
      },
    );
  }

  void reconnet() async {
    await Future.delayed(Duration(seconds: 5));
    connect();
  }

  void sendMessage(Map<String, dynamic> message) {
    _channel.sink.add(
      json.encode(message),
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

      debugPrint("$getToken token wsHelper");
      debugPrint("${prefs.getString('lastRequest')} exp wsHelper");

      if (now.difference(lastRequest).inHours >= 1) {
        _channel.sink.add(json.encode(
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
        () => _channel.sink.add(json.encode(
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
          yield status['status'];
        }
      }
    } catch (e) {
      debugPrint("$e error in verifikasi");
    }
  }

  Stream<List<BorrowUser>> checkUserHasBorrow() async* {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final getToken = prefs.getString('token');

    try {
      _channel.sink.add(json.encode(
        {
          "endpoint": "checkUserBorrow",
          "data": {
            "token": getToken,
          }
        },
      ));
      final List<BorrowUser> list = [];

      await for (final status in streamController.stream) {
        if (status['endpoint'] == "CHECKUSER") {
          for (var i = 0; i < status['message'].length; i++) {
            final Map dataMessage = status['message'][i];
            for (var data in dataMessage.values) {
              if (data is Map) {
                final user = BorrowUser.from(data);
                list.add(user);
              }
            }
            yield list;
          }
        }
      }
    } catch (e) {
      debugPrint("$e error in verifikasi");
    }
  }

  Stream<Map> responseLogin() async* {
    Map data = {};

    await for (var map in streamController.stream) {
      if (map['endpoint'] == 'LOGIN') {
        data.addAll(map);
        yield data;
      }
    }
  }

  Stream<Map> responseRegister() async* {
    Map data = {};

    await for (var map in streamController.stream) {
      if (map['endpoint'] == 'RIGISTER') {
        data.addAll(map);
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

        yield list;
      }
    }
  }

  Future<List<KeyCategoryList>> keyCategory() async {
    List<KeyCategoryList> key = [];

    await for (var data in streamController.stream) {
      if (data['endpoint'] == "GETDATAALLKEYCATEGORY") {
        for (var i = 0; i < data['message'].length; i++) {
          final keyCategory = KeyCategoryList.fromJson(data['message'][i]);
          key.add(keyCategory);
        }
        return key;
      }
    }
    return [];
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

        yield data;
      }
    }
  }

  void freeGrantedIfPastOneYear() {}

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
