import 'dart:math';

import 'package:flutter/material.dart';

class FlyingHeartsAnimation extends StatefulWidget {
  final int heartCount;
  const FlyingHeartsAnimation({super.key, required this.heartCount});

  @override
  State<FlyingHeartsAnimation> createState() => _FlyingHeartsAnimationState();
}

class _FlyingHeartsAnimationState extends State<FlyingHeartsAnimation>
    with TickerProviderStateMixin {
  final List<HeartAnimation> heartsAnimation = [];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.heartCount; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) {
          setState(() {
            heartsAnimation.add(
              HeartAnimation(
                controller: AnimationController(
                  duration: const Duration(seconds: 4),
                  vsync: this,
                )..forward(),
              ),
            );
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (var animation in heartsAnimation) {
      animation.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...heartsAnimation.map(
          (heart) => AnimatedBuilder(
            animation: heart.controller,
            builder: (context, child) {
              return Positioned(
                left: heart.leftTween.evaluate(heart.controller),
                bottom: heart.bottomTween.evaluate(heart.controller),
                child: Opacity(
                  opacity: heart.opacityTween.evaluate(heart.controller),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

class HeartAnimation {
  final AnimationController controller;
  late final Tween<double> leftTween;
  late final Tween<double> bottomTween;
  late final Tween<double> opacityTween;

  HeartAnimation({required this.controller}) {
    final random = Random();
    leftTween = Tween<double>(
      begin: random.nextDouble() * 300,
      end: random.nextDouble() * 300,
    );
    bottomTween = Tween<double>(
      begin: 0,
      end: 400 + random.nextDouble() * 100,
    );
    opacityTween = Tween<double>(begin: 1, end: 0);
  }
}
