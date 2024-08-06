import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class PreviewImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final double minScale;
  final double maxScale;
  const PreviewImageGallery({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
    this.maxScale = 2.5,
    this.minScale = 1.0,
  });

  @override
  State<PreviewImageGallery> createState() => _PreviewImageGalleryState();
}

class _PreviewImageGalleryState extends State<PreviewImageGallery> with TickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();

  /// The current scale of the [InteractiveViewer].
  double get _scale => _transformationController.value.row0.x;
  var _currentIndex = 0;
  bool _enablePageView = true;

  /// Handle double tap to zoom in/out
  late Offset _doubleTapLocalPosition;

  /// The controller to animate the transformation value of the
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  /// For handle drag to pop action
  late final AnimationController _dragAnimationController;

  /// Drag offset animation controller.
  late Animation<Offset> _dragAnimation;
  Offset? _dragOffset;
  Offset? _previousPosition;

  /// Flag to enabled/disabled drag to pop action
  bool _enableDrag = true;

  /// Animate hide bar
  late final AnimationController _hidePercentController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  late final Animation<double> _aniHidePercent =
      Tween<double>(begin: 1.0, end: 0.0).animate(_hidePercentController);
  bool _isTapScreen = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        _transformationController.value = _animation?.value ?? Matrix4.identity();
      });

    /// initial drag animation controller
    _dragAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addStatusListener((status) {
        _onAnimationEnd(status);
      });
    _dragAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_dragAnimationController);

    /// initial hide bar animation
    _hidePercentController.addListener(() {
      if (_hidePercentController.status == AnimationStatus.dismissed) {
        _delayHideMenu();
      }
    });
  }

  _checkShowBar() {
    if (_aniHidePercent.value <= 0) {
      _hidePercentController.reverse();
    } else {
      _hidePercentController.forward();
    }
  }

  Future _delayHideMenu() async {
    if (_isTapScreen) return;
    await _hidePercentController.forward();
  }

  void _onAnimationEnd(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _dragAnimationController.reset();
      setState(() {
        _dragOffset = null;
        _previousPosition = null;
      });
    }
  }

  @override
  void dispose() {
    _hidePercentController.dispose();
    _dragAnimationController.removeStatusListener(_onAnimationEnd);
    _dragAnimationController.dispose();
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.loose,
          children: [
            _buildImageSliders(context),
            _buildToolbar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return AnimatedBuilder(
      animation: _aniHidePercent,
      builder: (context, child) {
        return Opacity(
          opacity: _aniHidePercent.value,
          child: child,
        );
      },
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: SizedBox(
          height: kToolbarHeight,
          child: AppBar(
            toolbarHeight: kToolbarHeight,
            backgroundColor: Colors.transparent,
            title: Text(
              '${_currentIndex + 1}/${widget.imageUrls.length}',
              style:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18.0),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSliders(BuildContext context) {
    return AnimatedBuilder(
      builder: (context, Widget? child) {
        Offset finalOffset = _dragOffset ?? const Offset(0.0, 0.0);
        if (_dragAnimation.status == AnimationStatus.forward) finalOffset = _dragAnimation.value;
        return Transform.translate(
          offset: finalOffset,
          child: child,
        );
      },
      animation: _dragAnimation,
      child: CarouselSlider(
        disableGesture: true,
        items: widget.imageUrls
            .map(
              (e) => InteractiveViewer(
                minScale: widget.minScale,
                maxScale: widget.maxScale,
                transformationController: _transformationController,
                onInteractionUpdate: (details) {
                  _onDragUpdate(details);
                  if (_scale == 1.0) {
                    _enablePageView = true;
                    _enableDrag = true;
                  } else {
                    _enablePageView = false;
                    _enableDrag = false;
                  }
                  setState(() {});
                },
                onInteractionEnd: (details) {
                  if (_enableDrag) {
                    _onOverScrollDragEnd(details);
                  }
                },
                onInteractionStart: (details) {
                  if (_enableDrag) {
                    _onDragStart(details);
                  }
                },
                child: Hero(
                  tag: 'img_${widget.imageUrls.indexOf(e)}',
                  child: GestureDetector(
                    onDoubleTapDown: (TapDownDetails details) {
                      _doubleTapLocalPosition = details.localPosition;
                    },
                    onDoubleTap: _onDoubleTap,
                    child: Image.network(
                      e,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
        options: CarouselOptions(
          initialPage: _currentIndex,
          aspectRatio: 1.0,
          viewportFraction: 1.0,
          height: MediaQuery.of(context).size.height,
          scrollPhysics: _enablePageView ? null : const NeverScrollableScrollPhysics(),
          enlargeCenterPage: false,
          onPageChanged: (index, reason) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  void _onDragStart(ScaleStartDetails scaleDetails) {
    _previousPosition = scaleDetails.focalPoint;
  }

  void _onDragUpdate(ScaleUpdateDetails scaleUpdateDetails) {
    final currentPosition = scaleUpdateDetails.focalPoint;
    final previousPosition = _previousPosition ?? currentPosition;

    final newY = (_dragOffset?.dy ?? 0.0) + (currentPosition.dy - previousPosition.dy);
    _previousPosition = currentPosition;
    if (_enableDrag) {
      setState(() {
        _dragOffset = Offset(0, newY);
      });
    }
  }

  /// Handles the end of an over-scroll drag event.
  ///
  /// If [scaleEndDetails] is not null, it checks if the drag offset exceeds a certain threshold
  /// and if the velocity is fast enough to trigger a pop action. If so, it pops the current route.
  void _onOverScrollDragEnd(ScaleEndDetails? scaleEndDetails) {
    if (_dragOffset == null) return;
    final dragOffset = _dragOffset!;

    final screenSize = MediaQuery.of(context).size;

    if (scaleEndDetails != null) {
      if (dragOffset.dy.abs() >= screenSize.height / 3) {
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
      final velocity = scaleEndDetails.velocity.pixelsPerSecond;
      final velocityY = velocity.dy;

      /// Make sure the velocity is fast enough to trigger the pop action
      /// Prevent mistake zoom in fast and drag => check dragOffset.dy.abs() > thresholdOffsetYToEnablePop
      const thresholdOffsetYToEnablePop = 75.0;
      const thresholdVelocityYToEnablePop = 200.0;
      if (velocityY.abs() > thresholdOffsetYToEnablePop &&
          dragOffset.dy.abs() > thresholdVelocityYToEnablePop &&
          _enableDrag) {
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
    }

    /// Reset position to center of the screen when the drag is canceled.
    setState(() {
      _dragAnimation = Tween<Offset>(
        begin: Offset(0.0, dragOffset.dy),
        end: const Offset(0.0, 0.0),
      ).animate(_dragAnimationController);
      _dragOffset = const Offset(0.0, 0.0);
      _dragAnimationController.forward();
    });
  }

  _onDoubleTap() {
    /// clone matrix4 current
    Matrix4 matrix = _transformationController.value.clone();

    /// Get the current value to see if the image is in zoom out or zoom in state
    final double currentScale = matrix.row0.x;

    /// Suppose the current state is zoom out
    double targetScale = widget.minScale;

    /// Determines the state after a double tap action exactly
    if (currentScale <= widget.minScale) {
      targetScale = widget.maxScale;
    }

    /// calculate new offset of double tap
    final double offSetX =
        targetScale == widget.minScale ? 0.0 : -_doubleTapLocalPosition.dx * (targetScale - 1);
    final double offSetY =
        targetScale == widget.minScale ? 0.0 : -_doubleTapLocalPosition.dy * (targetScale - 1);

    matrix = Matrix4.fromList([
      targetScale,
      matrix.row1.x,
      matrix.row2.x,
      matrix.row3.x,
      matrix.row0.y,
      targetScale,
      matrix.row2.y,
      matrix.row3.y,
      matrix.row0.z,
      matrix.row1.z,
      targetScale,
      matrix.row3.z,
      offSetX,
      offSetY,
      matrix.row2.w,
      matrix.row3.w
    ]);

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: matrix,
    ).animate(
      CurveTween(curve: Curves.easeOut).animate(_animationController),
    );
    _animationController.forward(from: 0);
  }
}
