import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenView extends StatefulWidget {
  String imageUrl;
  FullScreenView({super.key, required this.imageUrl});

  @override
  State<FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> with TickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: CloseButton(style: ButtonStyle(iconSize: MaterialStateProperty.all(30))),
      body: PhotoView(
        imageProvider: NetworkImage(widget.imageUrl),
        backgroundDecoration: BoxDecoration(color: Color(0xffF0DFC8)),
      ),
    );
  }
}

class FullScreenView_imageBytes extends StatefulWidget {
  Uint8List imageBytes;
  FullScreenView_imageBytes({super.key, required this.imageBytes});

  @override
  State<FullScreenView_imageBytes> createState() => _FullScreenView_imageBytesState();
}

class _FullScreenView_imageBytesState extends State<FullScreenView_imageBytes> with TickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: CloseButton(style: ButtonStyle(iconSize: MaterialStateProperty.all(30))),
      body: PhotoView(
        imageProvider: MemoryImage(widget.imageBytes),
        backgroundDecoration: BoxDecoration(color: Color(0xffF0DFC8)),
      ),
    );
  }
}
