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

  factory Index.fromJson(Map<String, dynamic> jsons, String index,
      String category, Uint8List imageList) {
    return Index(
      name: jsons['name'],
      status: jsons['status'],
      label: jsons['Label'],
      image: imageList,
      index: index,
      category: category,
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "nameItem": name,
        "label": label,
        "image": image,
      };
}
