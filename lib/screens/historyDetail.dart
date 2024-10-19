import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/youtubeVideo.dart';
import '../utils/artworkDisplay.dart';
import '../utils/historyUtils.dart';
import 'historyEdit.dart';

class HistoryDetailAppBar extends StatelessWidget implements PreferredSizeWidget{
  const HistoryDetailAppBar({super.key, required this.box, required this.boxKey, required this.onEditPressed});
  final Box box;
  final String boxKey;
  final Function onEditPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Column(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 55,
          ),
          SizedBox(height: 5)
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.edit, size: 35),
          onPressed: () => onEditPressed(),
        ),
        IconButton(
          icon: Icon(Icons.delete_forever, size: 35),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    contentPadding: EdgeInsets.fromLTRB(30, 30, 0, 20),
                    content: Text(
                      "이 기록을 삭제하시겠습니까?",
                      style: TextStyle(fontSize: 17),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('취소')),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            box.delete(boxKey);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("기록이 삭제되었습니다."),
                            ));
                          },
                          child: Text('확인')),
                    ],
                  );
                });
          },
        ),
      ],
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.0);
}

class HistoryDescription extends StatelessWidget {
  const HistoryDescription({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20),
        child: Text(
          text,
          style: TextStyle(fontSize: 20),
        )
    );
  }
}


class AnalyzeHistoryDetail extends StatefulWidget {
  const AnalyzeHistoryDetail({super.key, required this.boxKey});
  final String boxKey;

  @override
  State<AnalyzeHistoryDetail> createState() => _AnalyzeHistoryDetailState();
}

class _AnalyzeHistoryDetailState extends State<AnalyzeHistoryDetail> {
  Box analyzeBox = Hive.box("analyzeHistory");
  late Uint8List imageBytes;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addBoxListener(this, analyzeBox);
    imageBytes = analyzeBox.get(widget.boxKey)['image'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HistoryDetailAppBar(box: analyzeBox, boxKey: widget.boxKey, onEditPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyzeHistoryEdit(boxKey: widget.boxKey)));
      }),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ImageAndButtons_imageBytes(imageBytes: imageBytes),
            HistoryDescription(text: analyzeBox.get(widget.boxKey)['text']),
            SizedBox(height: 40,)
          ],
        ),
      ),
    );
  }
}

class ImproveHistoryDetail extends StatefulWidget {
  const ImproveHistoryDetail({super.key, required this.boxKey});
  final String boxKey;

  @override
  State<ImproveHistoryDetail> createState() => _ImproveHistoryDetailState();
}

class _ImproveHistoryDetailState extends State<ImproveHistoryDetail> {
  Box improveBox = Hive.box("improveHistory");
  late Uint8List imageBytes;
  late List<YouTubeVideo> videos;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addBoxListener(this, improveBox);
    imageBytes = improveBox.get(widget.boxKey)['image'];
    videos = (improveBox.get(widget.boxKey)['youtube'] as List).cast<YouTubeVideo>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HistoryDetailAppBar(box: improveBox, boxKey: widget.boxKey, onEditPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ImproveHistoryEdit(boxKey: widget.boxKey)));
      }),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ImageAndButtons_imageBytes(imageBytes: imageBytes),
            HistoryDescription(text: improveBox.get(widget.boxKey)['text']),
            YoutubeVideosDisplay(videos: videos, keyword: improveBox.get(widget.boxKey)['keyword'],),
            SizedBox(height: 40,)
          ],
        ),
      ),
    );
  }
}

