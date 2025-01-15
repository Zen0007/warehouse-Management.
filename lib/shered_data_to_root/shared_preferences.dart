import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StoredUserChoice {
  Future<void> saveListToSharedPreferences(
      List<Map<String, dynamic>> choise) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String jsonString = json.encode(choise);
    await pref.setString("choice", jsonString);
  }

  Future<List<Map<String, dynamic>>> getListFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString("choice");
    if (jsonString != null) {
      final List jsonList = json.decode(jsonString);
      return jsonList.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<void> delete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // ignore: unused_local_variable
    final remove = await prefs.remove("choice");
  }

  Future<void> addNewMapToSharedPreferences(
      Map<String, dynamic> newChoice) async {
    List<Map<String, dynamic>> list = await getListFromSharedPreferences();
    bool check = list.any((item) => item['label'] == newChoice['label']);
    if (!check) {
      list.add(newChoice);
      await saveListToSharedPreferences(list);
    }
  }

  Future<void> deleteItem(String label) async {
    List<Map<String, dynamic>> list = await getListFromSharedPreferences();
    list.removeWhere((item) => item['label'] == label);
    await saveListToSharedPreferences(list);
  }
}
