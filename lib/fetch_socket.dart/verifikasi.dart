import 'package:werehouse_inventory/dummy_data/data_login.dart';

Stream<Map> verifikasi(String token) async* {
  if (!dataAdmin.containsKey(token)) {
    yield {
      "endpoint": "verikasi",
      "warnig": "",
    };
  }
  if (token.isEmpty) {
    yield {
      "endpoint": "verikasi",
      "warning": "",
    };
  }
  yield {
    "endpoint": "verikasi",
    "message": "VERIFIKASI",
  };
}
