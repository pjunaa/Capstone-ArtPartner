import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/youtubeVideo.dart';

void addBoxListener(State state, Box box) {
  box.listenable().addListener(() {
    if (state.mounted) {
      state.setState(() {});
    }
  });
}

void _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class YoutubeVideosDisplay extends StatelessWidget {
  const YoutubeVideosDisplay({super.key, required this.videos, required this.keyword});
  final List<YouTubeVideo> videos;
  final String keyword;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        title: Text(
          '$keyword 관련 YouTube 동영상',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: videos.map((video){
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0), // 각 콘텐츠 사이의 공백
                    child: GestureDetector(
                      onTap: () {
                        // 클릭하면 해당 URL을 열음
                        final videoUrl = 'https://www.youtube.com/watch?v=${video.videoId}';
                        _launchURL(videoUrl);
                      },
                      child: Column(
                        children: [
                          Image.network(
                            video.thumbnailUrl,
                            width: 150,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 4), // 썸네일과 제목 사이 간격
                          Container(
                            width: 120,
                            child: Text(
                              video.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis, // 제목이 길 경우 생략
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList()
            ),
          )
        ]
    );
  }
}