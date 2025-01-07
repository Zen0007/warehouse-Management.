import 'dart:convert';

import 'package:werehouse_inventory/dummy_data/decode.dart';

String jsonData = '''
[
    {
        "status": "borrow",
        "name": "asta",
        "class": "xi",
        "nameTeacher": "yami",
        "nisn": "12345678",
        "imageSelfie": "-",
        "imageStudentCard": "-",
        "items": [
            {
                "category": "accessPoint",
                "id": "1",
                "label": "no 123",
                "nameItem": "tp Link",
                "image": "-",
                "status": "available"
            },
            {
                "category": "accessPoint",
                "id": "2",
                "label": "no 123",
                "nameItem": "tp Link",
                "image": "-",
                "status": "available"
            },
            {
                "category": "mikrotick",
                "id": "1",
                "label": "no 2",
                "nameItem": "cisco",
                "image": "-",
                "status": "available"
            }
        ]
    },
    {
        "status": "borrow",
        "name": "yuno",
        "class": "xi",
        "nameTeacher": "yami",
        "nisn": "12345678",
        "imageSelfie": "-",
        "imageStudentCard": "-",
        "items": [
            {
                "category": "accessPoint",
                "id": "1",
                "label": "no 123",
                "nameItem": "tp Link",
                "image": "-",
                "status": "available"
            },
            {
                "category": "accessPoint",
                "id": "2",
                "label": "no 123",
                "nameItem": "tp Link",
                "image": "-",
                "status": "available"
            },
            {
                "category": "mikrotick",
                "id": "1",
                "label": "no 2",
                "nameItem": "cisco",
                "image": "-",
                "status": "available"
            }
        ]
    }
]
''';

Stream<List<BorrowUser>> borrowUserDummy() async* {
  List jsonDecode = json.decode(jsonData);
  List<BorrowUser> listBorrow = [];

  for (var i = 0; i < jsonDecode.length; i++) {
    final user = BorrowUser.from(jsonDecode[i]);
    listBorrow.add(user);
  }
  yield listBorrow;
}
