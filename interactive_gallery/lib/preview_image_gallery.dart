import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class PreviewImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  const PreviewImageGallery({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<PreviewImageGallery> createState() => _PreviewImageGalleryState();
}

class _PreviewImageGalleryState extends State<PreviewImageGallery> {
  var _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
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
          items: widget.imageUrls
              .map(
                (e) => Image.network(
                  e,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
              .toList(),
          options: CarouselOptions(
            initialPage: _currentIndex,
            aspectRatio: 1.0,
            viewportFraction: 1.0,
            height: MediaQuery.of(context).size.height,
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
}
