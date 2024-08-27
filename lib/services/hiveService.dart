import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/youtubeVideo.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter<YouTubeVideo>(YouTubeVideoAdapter());
    }
    await Hive.openBox("analyzeHistory");
    await Hive.openBox("improveHistory");
  }
}