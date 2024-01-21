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

class _PreviewImageGalleryState extends State<PreviewImageGallery>
    with SingleTickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
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
            )),
        body: CarouselSlider(
          disableGesture: true,
          items: widget.imageUrls
              .map(
                (e) => InteractiveViewer(
                  transformationController: _transformationController,
                  onInteractionStart: (details) {
                    if (_scale == 1.0) {
                      _enablePageView = true;
                    } else {
                      _enablePageView = false;
                    }
                    setState(() {});
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
      ),
    );
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
