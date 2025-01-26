import 'dart:typed_data';

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
