import 'package:werehouse_inventory/dummy_data/image.dart';

Stream<List<Map>> retrunData() async* {
  final data = [
    [
      {
        "name": "asta",
        "kelas": "vvi",
        "guru": "reja",
        "nisn": "1233344",
        "image": image
      }
    ],
    [
      {
        "name": "yuno",
        "kelas": "vvi",
        "guru": "reja",
        "nisn": "1233344",
        "image": image
      }
    ],
    [
      {
        "name": "yuno",
        "kelas": "vvi",
        "guru": "reja",
        "nisn": "1233344",
        "image": image
      }
    ],
    [
      {
        "name": "yuno",
        "kelas": "vvi",
        "guru": "reja",
        "nisn": "1233344",
        "image": image
      }
    ]
  ];
  for (var el in data) {
    yield el;
  }
}
