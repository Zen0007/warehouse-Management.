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
