import 'dart:typed_data';

import 'package:artpartner001/utils/historyUtils.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/youtubeVideo.dart';

class HistoryEditAppBar extends StatelessWidget implements PreferredSizeWidget{
  const HistoryEditAppBar({super.key, required this.onPressed});
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Column(
        children: [
          Image.asset('assets/images/logo.png', height: 55,),
          SizedBox(height: 5)
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.check, size: 35),
          onPressed: onPressed,
        ),
      ],
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.0);
}


class ImageDisplay extends StatelessWidget {
  const ImageDisplay({super.key, required this.imageBytes});
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    if(imageBytes != null) {
      return Image.memory(imageBytes!);
    } else{
      return Text('No image saved');
    }
  }
}

class TextEditField extends StatelessWidget {
  const TextEditField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: TextField(
        controller: controller,
        maxLines: null,
        style: TextStyle(fontSize: 20),
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class AnalyzeHistoryEdit extends StatefulWidget {
  const AnalyzeHistoryEdit({super.key, required this.boxKey});
  final String boxKey;

  @override
  State<AnalyzeHistoryEdit> createState() => _AnalyzeHistoryEditState();
}

class _AnalyzeHistoryEditState extends State<AnalyzeHistoryEdit> {
  Box analyzeBox = Hive.box("analyzeHistory");
  late Uint8List imageBytes;
  late TextEditingController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imageBytes = analyzeBox.get(widget.boxKey)['image'];
    _controller = TextEditingController(text: analyzeBox.get(widget.boxKey)['text']);
  }

  void saveAnalyzeText() async{
    analyzeBox.put(
        widget.boxKey, {
      'image': imageBytes,
      'text': _controller.text
    }
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("기록이 수정되었습니다."),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HistoryEditAppBar(onPressed: saveAnalyzeText),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ImageDisplay(imageBytes: imageBytes),
            TextEditField(controller: _controller),
            SizedBox(height: 40,)
          ],
        ),
      ),
    );
  }
}

class ImproveHistoryEdit extends StatefulWidget {
  const ImproveHistoryEdit({super.key, required this.boxKey});
  final String boxKey;

  @override
  State<ImproveHistoryEdit> createState() => _ImproveHistoryEditState();
}

class _ImproveHistoryEditState extends State<ImproveHistoryEdit> {
  Box improveBox = Hive.box("improveHistory");
  late Uint8List imageBytes;
  late List<YouTubeVideo> videos;
  late TextEditingController _controller;
  late String keyword;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imageBytes = improveBox.get(widget.boxKey)['image'];
    _controller = TextEditingController(text: improveBox.get(widget.boxKey)['text']);
    videos = (improveBox.get(widget.boxKey)['youtube'] as List).cast<YouTubeVideo>();
    keyword = improveBox.get(widget.boxKey)['keyword'];
  }

  void saveImproveText() async{
    improveBox.put(
        widget.boxKey, {
      'image': imageBytes,
      'text': _controller.text,
      'youtube': videos,
      'keyword': keyword
    }
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("기록이 수정되었습니다."),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  HistoryEditAppBar(onPressed: saveImproveText),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ImageDisplay(imageBytes: imageBytes),
            TextEditField(controller: _controller),
            YoutubeVideosDisplay(videos: videos, keyword: improveBox.get(widget.boxKey)['keyword'],),
            SizedBox(height: 40,)
          ],
        ),
      ),
    );
  }
}
