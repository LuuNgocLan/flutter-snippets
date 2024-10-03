import 'package:animation/social_feed_item.dart';
import 'package:flutter/material.dart';

class MasonryList extends StatefulWidget {
  final List<String> children;
  final double itemSpacing;

  const MasonryList({
    super.key,
    required this.children,
    this.itemSpacing = 8.0,
  });

  @override
  State<MasonryList> createState() => _MasonryListState();
}

class _MasonryListState extends State<MasonryList> with TickerProviderStateMixin {
  final _leftScrollController = ScrollController();
  final _rightScrollController = ScrollController();
  late AnimationController _leftAutoScrollController;
  late AnimationController _rightAutoScrollController;
  late AnimationController _heartAnimationController;
  bool _isAutoScrolling = true;
  int _currentAnimatingItemIndex = 0;

  @override
  void initState() {
    super.initState();
    _leftAutoScrollController = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 2),
    )..addListener(_leftAutoScroll);

    _rightAutoScrollController = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 2),
    )..addListener(_rightAutoScroll);

    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.children.isNotEmpty) {
        final middleIndex = widget.children.length ~/ 2;
        final leftTargetIndex = middleIndex ~/ 2;
        final rightTargetIndex = middleIndex ~/ 2;

        _scrollToIndex(_leftScrollController, leftTargetIndex, reverse: true);
        _scrollToIndex(_rightScrollController, rightTargetIndex, reverse: true);

        _startAutoScroll();

        _startHeartAnimation();
      }
    });
  }

  void _startHeartAnimation() {
    _heartAnimationController.forward(from: 0.0).then((_) {
      setState(() {
        _currentAnimatingItemIndex = (_currentAnimatingItemIndex + 1) % widget.children.length;
      });
      _heartAnimationController.reset();
      _startHeartAnimation();
    });
  }

  void _startAutoScroll() {
    if (_isAutoScrolling) {
      _leftAutoScrollController.repeat();
      _rightAutoScrollController.repeat();
    }
  }

  void _leftAutoScroll() {
    if (_isAutoScrolling && _leftScrollController.hasClients) {
      final newOffset =
          (_leftAutoScrollController.value * _leftScrollController.position.maxScrollExtent) %
              _leftScrollController.position.maxScrollExtent;
      _leftScrollController.jumpTo(newOffset);
    }
  }

  void _rightAutoScroll() {
    if (_isAutoScrolling && _rightScrollController.hasClients) {
      final newOffset =
          (_rightAutoScrollController.value * _rightScrollController.position.maxScrollExtent) %
              _rightScrollController.position.maxScrollExtent;
      _rightScrollController.jumpTo(newOffset);
    }
  }

  void _scrollToIndex(ScrollController controller, int index, {bool reverse = false}) {
    if (controller.hasClients) {
      const itemHeight = 221; // Assuming an average item height
      final targetOffset = index * (itemHeight + widget.itemSpacing);
      controller
          .jumpTo(reverse ? controller.position.maxScrollExtent - targetOffset : targetOffset);
    }
  }

  void _stopAutoScroll() {
    setState(() {
      _isAutoScrolling = false;
      _rightAutoScrollController.stop();
      _leftAutoScrollController.stop();
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
    _leftAutoScrollController.dispose();
    _rightAutoScrollController.dispose();
    _heartAnimationController.dispose();
    _leftScrollController.dispose();
    _rightScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _stopAutoScroll(),
      onTapUp: (_) => _resumeAutoScroll(),
      onVerticalDragStart: (_) => _stopAutoScroll(),
      onVerticalDragEnd: (_) => _resumeAutoScroll(),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: widget.itemSpacing),
          Expanded(
            flex: 1,
            child: ListView.builder(
              controller: _leftScrollController,
              itemCount: (widget.children.length + 1) ~/ 2,
              itemBuilder: (context, index) {
                return SocialFeedItem(
                    url: widget.children[index * 2],
                    isAnimating: index * 2 == _currentAnimatingItemIndex);
              },
            ),
          ),
          SizedBox(width: widget.itemSpacing),
          Expanded(
            flex: 1,
            child: ListView.builder(
              controller: _rightScrollController,
              itemCount: widget.children.length ~/ 2,
              itemBuilder: (context, index) {
                return SocialFeedItem(
                    url: widget.children[index * 2 + 1],
                    isAnimating: (index * 2 + 1) == _currentAnimatingItemIndex);
              },
              reverse: true,
            ),
          ),
          SizedBox(width: widget.itemSpacing),
        ],
      ),
    );
  }
}

class FlyingHeartAnimation extends StatelessWidget {
  final double progress;

  const FlyingHeartAnimation({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HeartPainter(progress: progress),
    );
  }
}

class HeartPainter extends CustomPainter {
  final double progress;

  HeartPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(1 - progress)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final heartSize = size.width * 0.2;

    final path = Path()
      ..moveTo(center.dx, center.dy + heartSize / 4)
      ..cubicTo(center.dx - heartSize / 2, center.dy - heartSize / 4, center.dx - heartSize,
          center.dy + heartSize / 4, center.dx, center.dy + heartSize)
      ..cubicTo(center.dx + heartSize, center.dy + heartSize / 4, center.dx + heartSize / 2,
          center.dy - heartSize / 4, center.dx, center.dy + heartSize / 4);

    final matrix = Matrix4.identity()
      ..translate(0.0, -size.height * progress * 0.5)
      ..scale(1 + progress * 0.5);

    canvas.transform(matrix.storage);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
