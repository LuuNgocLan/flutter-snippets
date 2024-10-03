import 'package:animation/masonry_feed.dart';
import 'package:flutter/material.dart';

class FeedScrollAnimationDemo extends StatefulWidget {
  const FeedScrollAnimationDemo({super.key});

  @override
  State<FeedScrollAnimationDemo> createState() => _FeedScrollAnimationDemoState();
}

class _FeedScrollAnimationDemoState extends State<FeedScrollAnimationDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Scroll Animation'),
      ),
      body: MasonryList(
        itemSpacing: 10,
        children: List.generate(20, (index) => 'https://picsum.photos/200/300?random=$index'),
      ),
    );
  }
}
