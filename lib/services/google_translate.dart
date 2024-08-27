library google_translate;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class GoogleTranslateReopsitory {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://translation.googleapis.com/",
  ));
  final completer = Completer();

  GoogleTranslateReopsitory({
    required Duration cacheDuration,
  }) {
    getTemporaryDirectory().then((cache) {
      _dio.interceptors.add(
        DioCacheInterceptor(
          options: CacheOptions(
            store: HiveCacheStore(
              cache.path,
              hiveBoxName: "google_translate_cache",
            ),
            maxStale: cacheDuration,
            policy: CachePolicy.forceCache,
            priority: CachePriority.high,
            hitCacheOnErrorExcept: [401, 404],
            allowPostMethod: false,
          ),
        ),
      );
      completer.complete();
    });
  }

  Future<String> translate({
    required String text,
    String? source,
    required String target,
    required String apiKey,
  }) async {
    await completer.future;

    try {
      Response response = await _dio.get(
        "language/translate/v2",
        queryParameters: {
          "key": apiKey,
          "q": text,
          "source": source,
          "target": target,
          "format": "text",
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 304) &&
          response.data?["data"]?["translations"] != null &&
          response.data["data"]?["translations"]?.length > 0) {
        text = response.data["data"]?["translations"].first["translatedText"];
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return text;
  }
}

extension Translate on String {
  // Translate your text from source to target language
  Future<String> translate({
    String? sourceLanguage,
    String? targetLanguage,
  }) {
    return GoogleTranslate().translate(
      this,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
  }
}

class GoogleTranslate {
  static GoogleTranslate? _singleton;

  final GoogleTranslateReopsitory _reopsitory;

  // apiKey: google cloud console api key
  @protected
  final String apiKey;
  // sourceLanguage: language of you text to translate
  String? sourceLanguage;
  // targetLanguage: language of your translated text
  String targetLanguage;

  // Initialize GoogleTranslateController singleton
  static GoogleTranslate initialize({
    required String apiKey,
    String? sourceLanguage,
    required String targetLanguage,
    Duration cacheDuration = const Duration(days: 7),
  }) {
    return _singleton = GoogleTranslate._internal(
        apiKey: apiKey,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        cacheDuration: cacheDuration);
  }

  // Get GoogleTranslateController already initialized
  factory GoogleTranslate() {
    assert(_singleton != null);
    return _singleton!;
  }

  GoogleTranslate._internal({
    required this.apiKey,
    required this.sourceLanguage,
    required this.targetLanguage,
    required Duration cacheDuration,
  }) : _reopsitory = GoogleTranslateReopsitory(cacheDuration: cacheDuration);

  // Translate your text from source to target language
  Future<String> translate(
      String text, {
        String? sourceLanguage,
        String? targetLanguage,
      }) {
    final source = sourceLanguage ?? this.sourceLanguage;
    final target = targetLanguage ?? this.targetLanguage;
    return _reopsitory.translate(
      text: text,
      source: source,
      target: target,
      apiKey: apiKey,
    );
  }
}