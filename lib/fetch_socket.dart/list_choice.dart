final map = [
  {
    'category': "accesPoint",
    'index': "1",
    'name': "ciscoo",
    'label': "l-401",
  },
  {
    'category': "accesPoint",
    'index': "1",
    'name': "ciscoo",
    'label': "l-402",
  },
  {
    'category': "accesPoint",
    'index': "1",
    'name': "ciscoo",
    'label': "l-403",
  },
  {
    'category': "accesPoint",
    'index': "1",
    'name': "ciscoo",
    'label': "l-404",
  },
  {
    'category': "accesPoint",
    'index': "1",
    'name': "ciscoo",
    'label': "l-405",
  },
  {
    'category': "accesPoint",
    'index': "1",
    'name': "ciscoo",
    'label': "l-406",
  },
  {
    'category': "accesPoint",
    'index': "1",
    'name': "ciscoo",
    'label': "l-407",
  },
  {
    'category': "accesPoint",
    'index': "1",
    'name': "ciscoo",
    'label': "l-408",
  },
  {
    'category': "accesPoint",
    'index': "1",
    'name': "ciscoo",
    'label': "l-409",
  },
  {
    'category': "accesPoint",
    'index': "1",
    'name': "ciscoo",
    'label': "l-500",
  },
  {
    'category': "accesPoint",
    'index': "1",
    'name': "ciscoo",
    'label': "l-501",
  }
];

Future<List<Map>> choice() async {
  return map;
}

void delet(String label) {
  map.removeWhere(
    (element) => element['label'] == label,
  );
}
