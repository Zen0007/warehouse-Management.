import 'package:flutter/material.dart';

class ResponsibleScreen extends StatelessWidget {
  const ResponsibleScreen({
    super.key,
    required this.lenght,
    required this.item,
  });
  final int lenght;
  final Widget item;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int count;
        double mainAxisExtent;
        // ignore: avoid_print
        print(constraints.maxWidth);
        if (constraints.maxWidth < 480) {
          count = 2;
          mainAxisExtent = constraints.maxWidth * 0.67;
        } else if (constraints.maxWidth < 700) {
          count = 3;
          mainAxisExtent = constraints.maxWidth * 0.5;
        } else if (constraints.maxWidth < 900) {
          count = 4;
          mainAxisExtent = constraints.maxWidth * 0.35;
        } else if (constraints.maxWidth < 1000) {
          count = 5;
          mainAxisExtent = constraints.maxWidth * 0.3;
        } else {
          count = 6;
          mainAxisExtent = constraints.maxWidth * 0.25;
        }
        return GridView.builder(
          shrinkWrap: true,
          itemCount: lenght,
          padding: const EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            mainAxisSpacing: 8,
            crossAxisSpacing: 1,
            mainAxisExtent: mainAxisExtent,
          ),
          itemBuilder: (context, index) {
            return item;
          },
        );
      },
    );
  }
}
