import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/youtubeVideo.dart';
import '../services/improve_api_service.dart';
import '../services/youtube_api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../widgets/appbar.dart';

class ArtImproveResult extends StatefulWidget {
  final File? selectedImage;

  const ArtImproveResult({Key? key, required this.selectedImage}) : super(key: key);

  @override
  State<ArtImproveResult> createState() => _MyArtImproveResultState();
}

class _MyArtImproveResultState extends State<ArtImproveResult> {
  final apiService = ApiService();
  String improveResult = ''; //gpt4v 결과
  bool improveLoading = false;
  String searchKeyword = ''; //gpt4v 결과 기반 관련 검색어
  late Future<List<YouTubeVideo>> futureVideos = Future.value([]);
  Box improveBox = Hive.box("improveHistory");
  Uint8List? ImageBytes;

  Future<void> setImage() async{
    if(widget.selectedImage != null){
      ImageBytes = await widget.selectedImage!.readAsBytes();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setImage().then((_){
      if (improveResult.isEmpty) {
        makeResult(); // 화면 실행 시 makeResult() 실행
      }
    });
  }

  makeResult() async {
    setState(() {
      improveLoading = true;
    });
    try {
      if (improveResult == '') {
        improveResult =
        await apiService.sendImageToGPT4Vision(image: widget.selectedImage!);
      }
    } catch (error) {
      _showErrorBar(error.toString());
    } finally {
      searchKeyword = getKeyword(improveResult);

      setState(() {
        improveLoading = false;
      });

      await Future.delayed(Duration(seconds: 3)); // 3초 딜레이 추가 - 429 에러 방지
      setState(() {
        futureVideos = searchYouTube(searchKeyword); // YouTube 검색
        futureVideos.then((videos){
          improveBox.put(
              DateTime.now().millisecondsSinceEpoch.toString(),
              {
                'image': ImageBytes,
                'text': improveResult,
                'youtube': videos,
                'keyword': searchKeyword,
              }
          );
        });
      });
    }
  }

  /* // gpt 3.5로 검색 키워드 추출 but, 429 error 발생

  getSearchKeywords() async {
    if (improveResult != ''){
      String shortImproveResult = '';

      if (improveResult.length > 80) {
        shortImproveResult = improveResult.substring(0, 80);
      } else {
        shortImproveResult = improveResult;
      }

      String result = await apiService.sendMessageGPT(input_string: shortImproveResult); // gpt 3.5로 검색 키워드 추출

      setState(() {
        searchKeyword = result;
        futureVideos = searchYouTube(searchKeyword); // YouTube 검색
      });
    }
  }
   */


  void _showErrorBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String getKeyword(String myInput) {
    // '1.'과 ':' 사이의 문자열 추출(정규 표현식 이용)
    RegExp regExp = RegExp(r'1\.\s*(.*?):');
    Match? match = regExp.firstMatch(myInput);

    if (match != null) {
      String? keywords = match.group(1);
      if (keywords != null) {
        return keywords; // 리턴 1
      }
    } else {
      // 만약 결과가 비었다면 '1. '과 ' ' 사이의 문자열 추출
      RegExp regExpTwo = RegExp(r'1\.\s*(\S+)');
      Match? matchTwo = regExpTwo.firstMatch(myInput);

      if (matchTwo != null) {
        String? keywordsTwo = matchTwo.group(1);
        if (keywordsTwo != null) {
          return keywordsTwo; // 리턴 2
        }
      }
    }
    return ''; // 결과가 없다면 빈 문자열 반환 (리턴 3)
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 이미지
            if (widget.selectedImage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.file(
                  widget.selectedImage!,
                  fit: BoxFit.contain,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '이미지를 찾을 수 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),

            improveLoading
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: SpinKitWave(
                color: Colors.blue,
                size: 30,
              ),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    improveResult,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ExpansionTile(
                title: Text(
                  '$searchKeyword 관련 YouTube 동영상',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                      fontWeight: FontWeight.bold,
                  ),
                ),
                children: <Widget>[
                  FutureBuilder<List<YouTubeVideo>>(
                    future: futureVideos,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('오류: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('관련 YouTube 콘텐츠가 없습니다.'));
                      } else {
                        final videos = snapshot.data!;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: videos.map((video) {
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
                            }).toList(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 40), // 페이지 하단 공백 추가
          ],
        ),
      ),
    );
  }
}