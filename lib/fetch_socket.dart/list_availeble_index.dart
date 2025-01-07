import 'dart:convert';

import 'package:werehouse_inventory/dummy_data/decode.dart';
import 'package:werehouse_inventory/dummy_data/json.dart';

Stream<List<Index>> returnListIndexUser() async* {
  final decode = json.decode(jsonData);

  final List<Index> list = [];
  for (var i = 0; i < decode.length; i++) {
    decode[i].forEach((key, value) {
      if (key != '_id') {
        value.forEach((key1, value1) {
          final index = Index.fromJson(value1, key1, key);
          list.add(index);
          // print(value1['label']);
        });
      }
    });
  }

  yield list;
}
