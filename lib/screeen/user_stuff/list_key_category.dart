import 'package:flutter/material.dart';

// grid item
class ListCategory extends StatelessWidget {
  const ListCategory({
    super.key,
    required this.category,
    required this.onSelectCategory,
  });

  final String category;
  final void Function() onSelectCategory;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        color: Theme.of(context).colorScheme.onPrimary,
        Icons.circle_outlined,
      ),
      title: Text(
        category,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      onTap: onSelectCategory,
    );
  }
}
