import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:werehouse_inventory/dummy_data/decode.dart';
import 'package:werehouse_inventory/dummy_data/json.dart';

Future<List<CategoryList>> returnListCategory() async {
  try {
    final decode = jsonDecode(jsonData);
    final List<CategoryList> list = [];

    for (var data in decode) {
      final category = CategoryList.fromJson(data);
      list.add(category);
    }
    return list;
  } catch (e, s) {
    // ignore: avoid_print
    print("$e           -----------------------");
    debugPrint("$s                   ||||||||||||||||||||||||");
    return [];
  }
}
