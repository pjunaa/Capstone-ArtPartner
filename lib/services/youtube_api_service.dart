import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/youtubeVideo.dart';

Future<List<YouTubeVideo>> searchYouTube(String query) async {
  int maxRe = 5; // 최대 검색 결과 개수

  const apiKey = 'AIzaSyA8Pln_AVB_xvFc8mbD5zuPnPjJAUXTocQ'; // YouTube API 키 값

  final encodedQuery = Uri.encodeComponent(query); // 파라미터가 공백이나 특수문자를 포함할 수 있으므로 인코딩 후 진행
  String videotype = '미술 ';
  String myCategoryId = '26'; // Howto&Style(26), Education(27), Anime/Animation(31)

  final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=$maxRe&q=$videotype$encodedQuery&videoCategoryId=$myCategoryId&key=$apiKey');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<YouTubeVideo> videos = [];

    for (var item in data['items']) {
      final video = YouTubeVideo(
        title: item['snippet']['title'],
        thumbnailUrl: item['snippet']['thumbnails']['default']['url'],
        videoId: item['id']['videoId'],
      );
      videos.add(video);
    }

    return videos;
  } else {
    throw Exception('에러 코드: ${response.statusCode}');
  }
}