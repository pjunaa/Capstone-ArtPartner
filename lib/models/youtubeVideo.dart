import 'package:hive/hive.dart';

part 'youtubeVideo.g.dart';

@HiveType(typeId: 0)
class YouTubeVideo {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String thumbnailUrl;

  @HiveField(2)
  final String videoId;

  YouTubeVideo({
    required this.title,
    required this.thumbnailUrl,
    required this.videoId,
  });
}
