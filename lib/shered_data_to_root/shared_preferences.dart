import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoredUserChoice {
  final storage = FlutterSecureStorage();

  Future<void> saveListToSharedPreferences(
      List<Map<String, dynamic>> choise) async {
    String jsonString = json.encode(choise);
    await storage.write(key: "choice", value: jsonString);
  }

  Future<List<Map<String, dynamic>>> getListFromSharedPreferences() async {
    String? jsonString = await storage.read(key: "choice");
    if (jsonString != null) {
      final List jsonList = json.decode(jsonString);
      return jsonList.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
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
