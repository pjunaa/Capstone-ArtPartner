import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/clevelandArtwork.dart';
import '../models/semaArtwork.dart';
import '../screens/artworkDescription.dart';
import '../screens/fullScreenView.dart';
import 'downloadImage.dart';

class ArtworkGridView<T> extends StatefulWidget {
  ArtworkGridView({
    required this.futureArtwork,
    required this.fetchMoreArtwork,
    required this.lastScrollOffset,
    required this.imageUrlExtractor,
    required this.showLoadMore,
  });

  final Future<List<T>>? futureArtwork;
  final Function fetchMoreArtwork;
  final double lastScrollOffset;
  final String Function(T) imageUrlExtractor;
  final bool showLoadMore;

  @override
  _ArtworkGridViewState<T> createState() => _ArtworkGridViewState<T>();
}

class _ArtworkGridViewState<T> extends State<ArtworkGridView<T>> {
  late double _lastScrollOffset;
  int loadedImages = 0;
  int errorImages = 0;
  int totalImages = 0;
  bool showImages = false;

  @override
  void initState() {
    super.initState();
    _lastScrollOffset = widget.lastScrollOffset;
    showImages = false;
  }

  void _checkShowImages() {
    if (loadedImages+errorImages == totalImages) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          showImages = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<T>>(
        future: widget.futureArtwork,
        builder: (context, snapshot) {
          if (widget.futureArtwork == null) {
            return Container();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            showImages = false;
            PaintingBinding.instance.imageCache.clear();
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('조건에 맞는 작품이 없습니다.');
          } else {
            loadedImages = 0;
            errorImages = 0;
            totalImages = snapshot.data!.length;

            return Stack(
              children: [
                if(!showImages)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification) {
                      final currentScrollOffset = notification.metrics.pixels;
                      final scrollSpeed = (currentScrollOffset - _lastScrollOffset).abs();
                      if (notification.metrics.extentAfter == 0) {
                        if (scrollSpeed < 50) {
                          widget.fetchMoreArtwork();
                        }
                      }
                      _lastScrollOffset = currentScrollOffset;
                    }
                    return true;
                  },
                  child: ListView(
                    children: [
                      MasonryGridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.all(10),
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final artwork = snapshot.data![index];
                          final imageUrl = widget.imageUrlExtractor(artwork);
                          if (imageUrl == null || imageUrl.isEmpty) {
                            return Container();
                          } else {
                            bool loadingStarted = true;
                            return GestureDetector(
                              onTap: () {
                                if (artwork is ClevelandArtwork) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ClevelandArtworkDescription(clevelandArtwork: artwork),),);
                                } else if (artwork is SemaArtwork) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => SemaArtworkDescription(semaArtwork: artwork),),);
                                }
                              },
                              child: Image.network(
                                imageUrl,
                                errorBuilder: (context, error, stackTrace) {
                                  errorImages++;
                                  _checkShowImages();
                                  return Container();
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    if (loadingStarted) {
                                      loadingStarted = false;
                                    } else {
                                      loadedImages++;
                                      _checkShowImages();
                                    }
                                  }
                                  if(showImages) return child;
                                  else return Container();
                                },
                              ),
                            );
                          }
                        },
                      ),
                      if (widget.showLoadMore && showImages)
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                          child: Center(
                            child: Icon(Icons.expand_more, size: 30),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }
}

Shadow getIconShadow(){
  return Shadow(
    blurRadius: 8.0,
    color: Colors.black38,
    offset: Offset(0.0, 2.0),
  );
}

class ImageAndButtons extends StatefulWidget {
  const ImageAndButtons({super.key, required this.imageUrl});
  final String? imageUrl;

  @override
  State<ImageAndButtons> createState() => _ImageAndButtonsState();
}

class _ImageAndButtonsState extends State<ImageAndButtons> {
  double? _imageHeight;
  double? _imageWidth;

  @override
  void initState() {
    super.initState();
    _getImageSize(widget.imageUrl!);
  }

  void _getImageSize(String imageUrl) {
    final Image image = Image.network(imageUrl);
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        setState(() {
          _imageHeight = info.image.height.toDouble();
          _imageWidth = info.image.width.toDouble();
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(widget.imageUrl != null){
      return Stack(
        children: [
          _imageHeight == null || _imageWidth == null
              ? Center(child: CircularProgressIndicator())
              : (_imageWidth! / _imageHeight! > 10)
              ? Container(
            width: MediaQuery.of(context).size.width,
            height: 100,
            child: Image.network(
              widget.imageUrl!,
              fit: BoxFit.cover,
            ),
          )
              : Image.network(
            widget.imageUrl!,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fitWidth,
          ),
          Positioned(
            child: IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenView(imageUrl: widget.imageUrl!)));
              },
              icon: Icon(Icons.fullscreen, color: Colors.white,
                shadows: [
                  getIconShadow()
                ],
              ),
              iconSize: 30,
            ),
            right: 0,
            bottom: 0,
          ),
          Positioned(
            child: IconButton(
              onPressed: () async{
                downloadImage(context, widget.imageUrl!);
              },
              icon: Icon(Icons.download, color: Colors.white,
                shadows: [
                  getIconShadow()
                ],
              ),
              iconSize: 30,
            ),
            right: 50,
            bottom: 0,
          ),
        ],
      );
    }else{
      return Text('No image saved');
    }
  }
}

class ImageAndButtons_imageBytes extends StatefulWidget {
  const ImageAndButtons_imageBytes({super.key, required this.imageBytes});
  final Uint8List? imageBytes;

  @override
  State<ImageAndButtons_imageBytes> createState() => _ImageAndButtons_imageBytesState();
}

class _ImageAndButtons_imageBytesState extends State<ImageAndButtons_imageBytes> {
  double? _imageHeight;
  double? _imageWidth;

  @override
  void initState() {
    super.initState();
    _getImageSize(widget.imageBytes!);
  }

  void _getImageSize(Uint8List imageBytes) {
    final Image image = Image.memory(imageBytes);
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        setState(() {
          _imageHeight = info.image.height.toDouble();
          _imageWidth = info.image.width.toDouble();
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(widget.imageBytes != null){
      return Stack(
        children: [
          _imageHeight == null || _imageWidth == null
              ? CircularProgressIndicator()
              : (_imageWidth! / _imageHeight! > 10)
              ? Container(
            width: MediaQuery.of(context).size.width,
            height: 100,
            child: Image.memory(
              widget.imageBytes!,
              fit: BoxFit.cover,
            ),
          )
              : Image.memory(
            widget.imageBytes!,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fitWidth,
          ),
          Positioned(
            child: IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenView_imageBytes(imageBytes: widget.imageBytes!)));
              },
              icon: Icon(Icons.fullscreen, color: Colors.white,
                shadows: [
                  getIconShadow()
                ],
              ),
              iconSize: 30,
            ),
            right: 0,
            bottom: 0,
          ),
          Positioned(
            child: IconButton(
              onPressed: () async{
                downloadImage_imageBytes(context, widget.imageBytes!);
              },
              icon: Icon(Icons.download, color: Colors.white,
                shadows: [
                  getIconShadow()
                ],
              ),
              iconSize: 30,
            ),
            right: 50,
            bottom: 0,
          ),
        ],
      );
    }else{
      return Text('No image saved');
    }
  }
}
