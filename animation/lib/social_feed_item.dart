import 'dart:math';

import 'package:animation/heart_overlay_demo.dart';
import 'package:flutter/material.dart';

class SocialFeedItem extends StatefulWidget {
  final String url;
  final bool isAnimating;

  const SocialFeedItem({super.key, required this.url, required this.isAnimating});

  @override
  _SocialFeedItemState createState() => _SocialFeedItemState();
}

class _SocialFeedItemState extends State<SocialFeedItem> with TickerProviderStateMixin {
  final List<HeartAnimation> heartsAnimation = [];
  final Random random = Random();
  @override
  void initState() {
    super.initState();
    _resetHearts();
  }

  @override
  void dispose() {
    for (var animation in heartsAnimation) {
      animation.controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(SocialFeedItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _resetHearts();
      // _heartController.forward(from: 0);
    } else if (!widget.isAnimating && oldWidget.isAnimating) {
      // _heartController.stop();
    }
  }

  void _resetHearts() {
    heartsAnimation.clear();
    for (int i = 0; i < 3; i++) {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      height: 221,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.network(
              widget.url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          if (widget.isAnimating)
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
      ),
    );
  }
}
