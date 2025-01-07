import 'dart:convert';
import 'package:werehouse_inventory/dummy_data/decode.dart';
import 'package:werehouse_inventory/dummy_data/json.dart';

Stream<List<Index>> returnListIndex(String title) async* {
  final decode = jsonDecode(jsonData);

  final List<Index> list = [];
  for (var data in decode) {
    if (data[title] != null) {
      data[title].forEach((keycoll, value) {
        final index = Index.fromJson(value, keycoll, title);
        list.add(index);
      });
    } else {
      yield [];
    }
  }
  yield list;
}
