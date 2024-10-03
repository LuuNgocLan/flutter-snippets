import 'dart:async';
import 'dart:math';

import 'package:animation/heart_overlay_demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class VerticalScrollAnimationPage extends StatefulWidget {
  const VerticalScrollAnimationPage({super.key});

  @override
  State<VerticalScrollAnimationPage> createState() => _VerticalScrollAnimationPageState();
}

class _VerticalScrollAnimationPageState extends State<VerticalScrollAnimationPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isAutoScrolling = true;
  final List<PinItem> _items = List.generate(50, (index) => PinItem(id: index));
  int _currentAnimatingIndex = 0;
  late Timer _animationTimer;
  late AnimationController _autoScrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _autoScrollController = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 5),
    )..addListener(_autoScroll);
    _startAutoScroll();
    _startSequentialAnimation();
  }

  void _startAutoScroll() {
    if (_isAutoScrolling) {
      _autoScrollController.forward(from: 0);
    }
  }

  void _autoScroll() {
    if (_isAutoScrolling && _scrollController.hasClients) {
      _scrollController.jumpTo(
          (_autoScrollController.value * _scrollController.position.maxScrollExtent) %
              _scrollController.position.maxScrollExtent);
    }
  }

  void _startSequentialAnimation() {
    _animationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _currentAnimatingIndex = (_currentAnimatingIndex + 1) % _items.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Moving Feed'),
      ),
      body: GestureDetector(
        onTapDown: (_) => _stopAutoScroll(),
        onTapUp: (_) => _resumeAutoScroll(),
        onVerticalDragStart: (_) => _stopAutoScroll(),
        onVerticalDragEnd: (_) => _resumeAutoScroll(),
        child: MasonryGridView.count(
          controller: _scrollController,
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return PinCard(
              item: _items[index],
              isAnimating: index == _currentAnimatingIndex,
            );
          },
        ),
      ),
    );
  }

  void _stopAutoScroll() {
    setState(() {
      _isAutoScrolling = false;
      _autoScrollController.stop();
    });
  }

  void _resumeAutoScroll() {
    setState(() {
      _isAutoScrolling = true;
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationTimer.cancel();
    _autoScrollController.dispose();
    super.dispose();
  }
}

class PinItem {
  final int id;
  PinItem({required this.id});
}

class PinCard extends StatefulWidget {
  final PinItem item;
  final bool isAnimating;

  const PinCard({super.key, required this.item, required this.isAnimating});

  @override
  _PinCardState createState() => _PinCardState();
}

class _PinCardState extends State<PinCard> with TickerProviderStateMixin {
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
  void didUpdateWidget(PinCard oldWidget) {
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
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                'https://picsum.photos/200/300?random=${widget.item.id}',
                fit: BoxFit.cover,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Pin ${widget.item.id}'),
          ),
        ],
      ),
    );
  }
}

// class HeartAnimation {
//   final double startX = 50 + (200 * DateTime.now().millisecondsSinceEpoch % 100) / 100;
//   final double endX = 50 + (200 * DateTime.now().millisecondsSinceEpoch % 100) / 100;
//   final double startY = 300;
//   final double endY = -50;
// }

// class PositionedHeartAnimation extends StatelessWidget {
//   final Animation<double> animation;
//   final HeartAnimation heart;

//   PositionedHeartAnimation({required this.animation, required this.heart});

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: animation,
//       builder: (context, child) {
//         return Positioned(
//           left: heart.startX + (heart.endX - heart.startX) * animation.value,
//           top: heart.startY + (heart.endY - heart.startY) * animation.value,
//           child: Opacity(
//             opacity: 1 - animation.value,
//             child: const Icon(Icons.favorite, color: Colors.red, size: 24),
//           ),
//         );
//       },
//     );
//   }
// }
