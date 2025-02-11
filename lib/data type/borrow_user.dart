import 'dart:typed_data';

import 'package:werehouse_inventory/data type/item.dart';

class BorrowUser {
  final String? nameUser;
  final String? classUser;
  final String? nameTeacher;
  final String? nisn;
  final String? admin;
  final String? time;
  final Uint8List imageUser;
  final List? imageNisn;
  final String? status;
  final List<Item> item;

  BorrowUser({
    this.nameUser,
    this.classUser,
    this.nameTeacher,
    this.nisn,
    required this.imageUser,
    this.imageNisn,
    this.status,
    this.admin,
    this.time,
    required this.item,
  });

  factory BorrowUser.from(Map json, Uint8List image) {
    final List<Item> items = [];
    for (var data in json['items']) {
      final index = Item.from(
        data["category"],
        data['index'],
        data['nameItem'],
        data['label'],
      );
      items.add(index);
    }

    return BorrowUser(
      nameUser: json['name'],
      classUser: json['class'],
      nameTeacher: json['nameTeacher'],
      nisn: json['nisn'],
      imageUser: image,
      imageNisn: json['imageSelfie'],
      status: json['status'],
      admin: json['admin'],
      time: json['time'],
      item: items,
    );
  }
}
