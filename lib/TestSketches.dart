import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/appbar.dart';
import 'dart:async';

class TestSketches extends StatelessWidget {
  const TestSketches({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchScreen(); // SearchScreen 클래스 호출
  }
}

class SearchScreen extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '생성할 이미지를 작성하세요',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_textController.text.isEmpty) {
                  _showWarningDialog(context); // 경고창 띄우기
                } else {
                  _navigateToResultScreen(context, _textController.text);
                }
              },
              child: Text('도안생성'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToResultScreen(BuildContext context, String description) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(description: description),
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
    final apiKey = "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"; // 여기에 DALL·E API 키를 입력하세요
    final url = Uri.parse('https://api.openai.com/v1/images/generations'); // 올바른 API 엔드포인트 사용

    // 코드 내에서 손그림 스타일 추가 설명 정의
    final additionalDescription = "realistic.";

    // 사용자가 입력한 설명과 추가 설명을 결합하여 프롬프트 생성
    final prompt = "$description. $additionalDescription";

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': prompt, // 결합된 프롬프트 전달
          'n': 1,
          'size': '1024x1024',
        }),
      ).timeout(Duration(seconds: 30)); // 타임아웃 설정 추가

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API Response: $data'); // API 응답 디버깅을 위해 콘솔에 출력

        // 응답 구조 확인 후 URL 추출
        if (data.containsKey('data') && data['data'].isNotEmpty) {
          setState(() {
            imageUrl = data['data'][0]['url'];
            isLoading = false; // 로딩 상태 해제
          });
        } else {
          // 데이터가 비어있거나 예상치 못한 구조일 때
          setState(() {
            isLoading = false;
          });
          print('No image URL found in the response.');
        }
      } else {
        // 오류 처리
        setState(() {
          isLoading = false; // 로딩 상태 해제
        });
        print('Failed to load image: ${response.statusCode}');
        // 필요시 사용자에게 오류 메시지 표시
      }
    } on TimeoutException catch (_) {
      // 타임아웃 처리
      setState(() {
        isLoading = false; // 로딩 상태 해제
      });
      print('Request timed out');
      // 필요시 사용자에게 타임아웃 메시지 표시
    } catch (error) {
      // 네트워크 또는 기타 오류 처리
      setState(() {
        isLoading = false; // 로딩 상태 해제
      });
      print('Error occurred: $error');
      // 필요시 사용자에게 오류 메시지 표시
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
                    ? CircularProgressIndicator() // 로딩 인디케이터
                    : imageUrl != null
                    ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  placeholder: (context, url) =>
                      CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error),
                )
                    : Text('Failed to generate image'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    // 다운로드 로직 추가
                  },
                  child: Text('다운로드'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true; // 재생성 시 로딩 상태로 설정
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
