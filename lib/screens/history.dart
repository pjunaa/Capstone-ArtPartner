import 'dart:typed_data';

import 'package:artpartner001/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../utils/historyUtils.dart';
import 'historyDetail.dart';


class HistoryTitle extends StatelessWidget {
  const HistoryTitle({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Text(text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )),
    );
  }
}

class HistoryGridView extends StatelessWidget {
  const HistoryGridView({super.key, required this.box, required this.onTap});
  final Box box;
  final Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      padding: EdgeInsets.all(10),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: box.length,
      itemBuilder: (context, index) {
        Uint8List imageBytes = box.getAt(index)['image'];
        return GestureDetector(
          onTap: () => onTap(index),
          child: imageBytes != null
              ? Image.memory(imageBytes)
              : Text('No image saved'),
        );
      },
    );
  }
}

class AnalyzeHistory extends StatefulWidget {
  const AnalyzeHistory({super.key});

  @override
  State<AnalyzeHistory> createState() => _AnalyzeHistoryState();
}

class _AnalyzeHistoryState extends State<AnalyzeHistory> {
  Box analyzeBox = Hive.box("analyzeHistory");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addBoxListener(this, analyzeBox);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BaseAppBar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HistoryTitle(text: '작품 분석 기록'),
              HistoryGridView(
                box: analyzeBox,
                onTap: (index) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyzeHistoryDetail(boxKey: analyzeBox.keyAt(index))));
                },
              )
            ],
          ),
        ));
  }
}

class ImproveHistory extends StatefulWidget {
  const ImproveHistory({super.key});

  @override
  State<ImproveHistory> createState() => _ImproveHistoryState();
}

class _ImproveHistoryState extends State<ImproveHistory> {
  Box improveBox = Hive.box("improveHistory");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addBoxListener(this, improveBox);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: BaseAppBar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HistoryTitle(text: '개선 방법 기록'),
              HistoryGridView(
                box: improveBox,
                onTap: (index) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ImproveHistoryDetail(boxKey: improveBox.keyAt(index))));
                },
              )
            ],
          ),
      )
    );
  }
}

