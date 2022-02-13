import 'package:flutter/material.dart';

class TestTextField extends StatelessWidget {
  const TestTextField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: TextField(
            minLines: null,
            maxLines: null,
          ),
        ),
      ),
    );
  }
}
