// ignore_for_file: public_member_api_docs

import 'package:creature_comfort/src/typedef.dart' show defStyle;
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Home Page',
                style: defStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
