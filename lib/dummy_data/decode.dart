import 'dart:typed_data';

class CategoryList {
  final String key;
  final String id;
  CategoryList({
    required this.key,
    required this.id,
  });

  factory CategoryList.fromJson(Map<String, dynamic> json) => CategoryList(
        key: json.keys.firstWhere(
          (key) => key != "_id",
        ),
        id: json['_id']['\$oid'],
      );
}

class Id {
  Id({
    required this.oid,
  });
  String oid;

  factory Id.fromJson(Map<String, dynamic> json) => Id(
        oid: json["/u0024oid"],
      );
  Map<String, dynamic> toJson() => {
        "\u0024oid": oid,
      };
}

class KeyCategoryList {
  final String key;
  final String id;
  KeyCategoryList({
    required this.key,
    required this.id,
  });

  factory KeyCategoryList.fromJson(Map<String, dynamic> json) =>
      KeyCategoryList(
        key: json['key'],
        id: json['id'],
      );
}

class Index {
  Index({
    required this.name,
    required this.status,
    required this.label,
    required this.image,
    required this.category,
    required this.index,
  });
  String status;
  String label;
  String name;
  Uint8List image;
  String index;
  String category;

  factory Index.fromJson(
      Map<String, dynamic> jsons, String index, String category) {
    final List<int> listInt = List<int>.from(jsons['image'] as List);
    final Uint8List intList = Uint8List.fromList(listInt);
    return Index(
        name: jsons['name'],
        status: jsons['status'],
        label: jsons['Label'],
        image: intList,
        index: index,
        category: category);
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "nameItem": name,
        "label": label,
        "image": image,
      };
}

class Item {
  final String category;
  final String index;
  final String nameItem;
  final String label;

  Item({
    required this.category,
    required this.index,
    required this.nameItem,
    required this.label,
  });

  factory Item.from(
          String category, String index, String nameItem, String label) =>
      Item(
        category: category,
        index: index,
        nameItem: nameItem,
        label: label,
      );
}

class BorrowUser {
  final String? nameUser;
  final String? classUser;
  final String? nameTeacher;
  final String? nisn;
  final Uint8List imageUser;
  final Uint8List? imageNisn;
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
    required this.item,
  });

  factory BorrowUser.from(Map json) {
    final List<Item> item = [];
    for (var data in json['items']) {
      final index = Item.from(
        data["category"],
        data['id'],
        data['nameItem'],
        data['label'],
      );
      item.add(index);
    }
    final List<int> listInt = List<int>.from(json['imageSelfie'] as List);
    final Uint8List intList = Uint8List.fromList(listInt);
    return BorrowUser(
      nameUser: json['name'],
      classUser: json['class'],
      nameTeacher: json['nameTeacher'],
      nisn: json['nisn'],
      imageUser: intList,
      imageNisn: json['imageStudenCard'],
      status: json['status'],
      item: item,
    );
  }
}
