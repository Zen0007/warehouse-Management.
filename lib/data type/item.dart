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
