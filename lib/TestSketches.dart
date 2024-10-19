import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'widgets/appbar.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

enum ImageMode { blackAndWhite, color }

class TestSketches extends StatelessWidget {
  const TestSketches({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchScreen(); // SearchScreen 클래스 호출
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textController = TextEditingController();
  ImageMode _imageMode = ImageMode.color; // 디폴트로 컬러 모드
  String? selectedTag; // 선택된 태그 저장

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 좌측 정렬
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: selectedTag == null
                    ? '생성할 이미지를 작성하세요'
                    : '추가할 설명을 작성하세요', // 태그가 있을 때 메시지 변경
                prefixIcon: IconButton(
                  icon: Icon(Icons.settings), // 설정 아이콘
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TagSearchScreen(
                          onTagSelected: (String tag) {
                            setState(() {
                              selectedTag = tag; // 태그 선택
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // 선택된 태그를 TextField 아래에 표시
          if (selectedTag != null)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Row(
                children: [
                  Text(
                    '선택된 태그: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text(selectedTag!),
                    deleteIcon: Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        selectedTag = null; // 태그 삭제
                      });
                    },
                  ),
                ],
              ),
            ),
          SizedBox(height: 20),
          // 흑백/컬러 선택
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('흑백'),
              Radio(
                value: ImageMode.blackAndWhite,
                groupValue: _imageMode,
                onChanged: (ImageMode? value) {
                  setState(() {
                    _imageMode = value!;
                  });
                },
              ),
              Text('컬러'),
              Radio(
                value: ImageMode.color,
                groupValue: _imageMode,
                onChanged: (ImageMode? value) {
                  setState(() {
                    _imageMode = value!;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          // 도안생성 버튼
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_textController.text.isEmpty && selectedTag == null) {
                  _showWarningDialog(context); // 경고창 띄우기
                } else {
                  String description = selectedTag ?? '';
                  if (_textController.text.isNotEmpty) {
                    description += '. ' + _textController.text;
                  }
                  _navigateToResultScreen(context, description);
                }
              },
              child: Text('도안생성'),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToResultScreen(BuildContext context, String description) {
    // 기본적으로 스케치 스타일 추가
    String basePrompt = '$description in sketch style, drawn in a hand-drawn style.';

    // 흑백 또는 컬러 모드에 따라 프롬프트 수정
    String modeDescription = _imageMode == ImageMode.blackAndWhite
        ? 'The image should be in black and white, with no colors.'
        : 'The image should be in full color, with vivid and realistic colors.';

    String fullDescription = '$basePrompt $modeDescription';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(description: fullDescription),
      ),
    );
  }

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('경고'),
          content: Text('생성할 이미지를 작성하세요.'),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// 태그 검색 화면
class TagSearchScreen extends StatelessWidget {
  final Function(String) onTagSelected;

  const TagSearchScreen({required this.onTagSelected, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> categories = {
      '정물화': ['과일', '꽃병', '그릇'],
      '풍경화': ['산', '바다', '숲'],
      '인물화': ['남자', '여자', '아이'],
    };

    return Scaffold(
      appBar: BaseAppBar(),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: categories.keys.map((category) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '# $category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: categories[category]!.map((subcategory) {
                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: () {
                      onTagSelected(subcategory);
                    },
                    child: Text(
                      subcategory,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class ResultScreen extends StatefulWidget {
  final String description;

  const ResultScreen({required this.description, Key? key}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String? imageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchImage(widget.description);
  }

  Future<void> _fetchImage(String description) async {
    final apiKey = "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"; // DALL·E API KEY
    final url = Uri.parse('https://api.openai.com/v1/images/generations');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': description,
          'n': 1,
          'size': '1024x1024',
        }),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('data') && data['data'].isNotEmpty) {
          setState(() {
            imageUrl = data['data'][0]['url'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } on TimeoutException catch (_) {
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _downloadImage(String url) async {
    try {
      if (await _requestPermission()) {
        var response = await Dio()
            .get(url, options: Options(responseType: ResponseType.bytes));

        final directory = await getExternalStorageDirectory();
        final dcimPath = directory?.path.replaceFirst(
            'Android/data/com.example.app/files', 'DCIM') ??
            '/storage/emulated/0/DCIM';
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = '$dcimPath/$fileName';

        await Directory(dcimPath).create(recursive: true);
        final file = File(filePath);
        await file.writeAsBytes(Uint8List.fromList(response.data));
        await ImageGallerySaver.saveFile(filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지가 갤러리에 저장되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지를 저장하기 위해 저장 권한이 필요합니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지를 저장하지 못했습니다: $e')),
      );
    }
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final androidVersion = androidInfo.version.sdkInt;

      if (androidVersion >= 33) {
        final photos = await Permission.photos.request();
        final videos = await Permission.videos.request();
        return photos.isGranted && videos.isGranted;
      } else {
        final storage = await Permission.storage.request();
        return storage.isGranted;
      }
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: isLoading
                    ? CircularProgressIndicator()
                    : imageUrl != null
                    ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  placeholder: (context, url) =>
                      CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error),
                )
                    : Text('이미지를 생성하지 못했습니다.'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: imageUrl != null
                      ? () {
                    _downloadImage(imageUrl!);
                  }
                      : null,
                  child: Text('다운로드'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    _fetchImage(widget.description);
                  },
                  child: Text('재생성'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('확인'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
