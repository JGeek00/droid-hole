// Taken from: https://stackoverflow.com/a/59124572

import 'package:flutter/material.dart';

class ShakeAnimation extends StatefulWidget {
  final Widget child;

  const ShakeAnimation({
    Key? key,
    required this.child
  }) : super(key: key);

  @override
  State<ShakeAnimation> createState() => ShakeAnimationState();
}

class ShakeAnimationState extends State<ShakeAnimation> with SingleTickerProviderStateMixin {
  AnimationController? controller;

  @override
  void initState() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 300), 
      vsync: this
    );
    super.initState();
  }

  shake() {
    controller!.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> offsetAnimation = Tween(
      begin: 0.0, 
      end: 40.0
    ).chain(
      CurveTween(curve: Curves.elasticIn)
    ).animate(controller!)..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller!.reverse();
      }
    });

    return AnimatedBuilder(
      animation: offsetAnimation, 
      child: widget.child,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.only(
            left: offsetAnimation.value + 50.0, 
            right: 50.0 - offsetAnimation.value
          ),
          child: child,
        );
      }
    );
  }
}