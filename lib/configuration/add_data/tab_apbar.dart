import 'package:flutter/material.dart';

class ScreenService extends StatelessWidget {
  const ScreenService({super.key, required this.title});

  final String title;
  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}
