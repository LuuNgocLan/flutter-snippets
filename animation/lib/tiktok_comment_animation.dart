import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

class Comment {
  final String username;
  final String avatarUrl;
  final String text;
  final bool isSpecial;

  Comment({
    required this.username,
    required this.avatarUrl,
    required this.text,
    this.isSpecial = false,
  });
}

class TikTokCommentStream extends StatefulWidget {
  final Stream<Comment> commentStream;

  const TikTokCommentStream({Key? key, required this.commentStream}) : super(key: key);

  @override
  _TikTokCommentStreamState createState() => _TikTokCommentStreamState();
}

class _TikTokCommentStreamState extends State<TikTokCommentStream> {
  final List<Comment> _comments = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.commentStream.listen(_addComment);
  }

  void _addComment(Comment comment) {
    setState(() {
      _comments.insert(0, comment);
      if (_comments.length > 10) {
        _comments.removeLast();
      }
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _comments.length,
      reverse: true,
      itemBuilder: (context, index) {
        return TikTokCommentAnimation(comment: _comments[index]);
      },
    );
  }
}

class TikTokCommentAnimation extends StatefulWidget {
  final Comment comment;

  const TikTokCommentAnimation({super.key, required this.comment});

  @override
  _TikTokCommentAnimationState createState() => _TikTokCommentAnimationState();
}

class _TikTokCommentAnimationState extends State<TikTokCommentAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5, curve: Curves.easeOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5, curve: Curves.easeOut),
    ));

    _controller.forward();

    // Auto-hide after 5 seconds
    Timer(const Duration(seconds: 5), () {
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: widget.comment.isSpecial
                    ? Colors.amber.withOpacity(0.3)
                    : Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                boxShadow: widget.comment.isSpecial
                    ? [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.comment.avatarUrl),
                      radius: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.comment.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.comment.text,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Example usage
class TikTokLiveCommentDemo extends StatelessWidget {
  const TikTokLiveCommentDemo({super.key});

  Stream<Comment> _mockCommentStream() async* {
    final comments = [
      Comment(
          username: "Alice",
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
          text: "Hello from New York! 🗽"),
      Comment(
          username: "Bob",
          avatarUrl: 'https://i.pravatar.cc/150?img=2',
          text: "Keep up the good work! 🎉"),
      Comment(
          username: "Charlie",
          avatarUrl: 'https://i.pravatar.cc/150?img=3',
          text: "Can you do a tutorial on this? 🤔",
          isSpecial: true),
      Comment(
          username: "David",
          avatarUrl: 'https://i.pravatar.cc/150?img=4',
          text: 'Greetings from Australia! 🦘',
          isSpecial: false),
      Comment(
          username: "Eva",
          avatarUrl: 'https://i.pravatar.cc/150?img=5',
          text: 'Wow, I learned so much! 🧠',
          isSpecial: true),
    ];

    for (var comment in comments) {
      await Future.delayed(const Duration(seconds: 2));
      yield comment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TikTok Live Comment Demo')),
      body: Stack(
        children: [
          // Your live stream video would go here
          Container(color: Colors.grey),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            height: 300,
            child: TikTokCommentStream(commentStream: _mockCommentStream()),
          ),
        ],
      ),
    );
  }
}

Stream<Comment> generateTestCommentStream() async* {
  final random = Random();
  final List<String> usernames = ['Alice', 'Bob', 'Charlie', 'David', 'Eva', 'Frank'];
  final List<String> avatars = [
    'https://i.pravatar.cc/150?img=1',
    'https://i.pravatar.cc/150?img=2',
    'https://i.pravatar.cc/150?img=3',
    'https://i.pravatar.cc/150?img=4',
    'https://i.pravatar.cc/150?img=5',
  ];
  final List<String> comments = [
    'Great stream! 👍',
    'Hello from New York! 🗽',
    'Keep up the good work! 🎉',
    'This is amazing! 😍',
    'First time here, loving it! 🌟',
    'Can you do a tutorial on this? 🤔',
    'Wow, I learned so much! 🧠',
    '''You're the best! 🏆''',
    'Greetings from Australia! 🦘',
    'This made my day! 😊',
  ];

  while (true) {
    await Future.delayed(Duration(seconds: 1 + random.nextInt(3)));
    final username = usernames[random.nextInt(usernames.length)];
    final avatar = avatars[random.nextInt(avatars.length)];
    final comment = comments[random.nextInt(comments.length)];
    final isSpecial = random.nextDouble() < 0.2; // 20% chance for a special comment

    yield Comment(
      username: username,
      avatarUrl: avatar,
      text: comment,
      isSpecial: isSpecial,
    );
  }
}
