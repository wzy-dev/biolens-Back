import 'package:flutter/material.dart';

class CustomScaleTransition extends StatefulWidget {
  final Widget widget;
  final ValueKey? key;
  _CustomScaleTransitionState createState() => _CustomScaleTransitionState();

  CustomScaleTransition({required this.widget, this.key});
}

class _CustomScaleTransitionState extends State<CustomScaleTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    _animation = Tween(begin: 1.0, end: 1.02).animate(_controller);

    _controller.forward();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Container(
      // alignment: Alignment.center,
      key: widget.key,
      child: ScaleTransition(
          scale: _animation, alignment: Alignment.center, child: widget.widget),
    );
  }
}
