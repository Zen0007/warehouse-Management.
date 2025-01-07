import 'package:werehouse_inventory/dummy_data/data_login.dart';

Stream<Map> login(String name, String password) async* {
  // ignore: avoid_print
  print(name);
  // ignore: avoid_print
  print(password);
  if (name.isEmpty || password.isEmpty) {
    yield {
      "endpoint": "LOGIN",
      "warning": "some field is not fill",
    };
  }
  if (!dataAdmin.containsKey(name)) {
    yield {
      "endpoint": "LOGIN",
      "warning": "username faild",
    };
  } else if (dataAdmin[name]!['password'] != password) {
    yield {
      "endpoint": "LOGIN",
      "warning": "password faild",
    };
  }

  yield {
    'endpoint': "LOGIN",
    "token": name,
  };
}
