import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'widgets/appbar.dart';
import 'constants/api_constants.dart';

// Subcategory 클래스를 정의합니다.
class Subcategory {
  final String nameKorean;
  final String descriptionEnglish;

  Subcategory({required this.nameKorean, required this.descriptionEnglish});
}

// 카테고리와 서브카테고리에 영어 설명을 추가합니다.
final Map<String, List<Subcategory>> categories = {
  '정물화': [
    Subcategory(nameKorean: '과일', descriptionEnglish: 'Fruit still life'),
    Subcategory(nameKorean: '꽃병', descriptionEnglish: 'Vase with flowers'),
    Subcategory(nameKorean: '그릇', descriptionEnglish: 'Dish or bowl'),
    Subcategory(nameKorean: '의자', descriptionEnglish: 'Chair'),
    Subcategory(nameKorean: '와인병', descriptionEnglish: 'Wine bottle'),
    Subcategory(nameKorean: '식탁보', descriptionEnglish: 'Tablecloth'),
    Subcategory(nameKorean: '찻잔', descriptionEnglish: 'Teacup'),
  ],
  '풍경화': [
    Subcategory(nameKorean: '산', descriptionEnglish: 'Mountain landscape'),
    Subcategory(nameKorean: '바다', descriptionEnglish: 'Sea or ocean view'),
    Subcategory(nameKorean: '숲', descriptionEnglish: 'Forest scenery'),
    Subcategory(nameKorean: '계곡', descriptionEnglish: 'Valley'),
    Subcategory(nameKorean: '오두막', descriptionEnglish: 'Cabin'),
    Subcategory(nameKorean: '건물', descriptionEnglish: 'Building'),
    Subcategory(nameKorean: '호수', descriptionEnglish: 'Lake'),
  ],
  '인물화': [
    Subcategory(nameKorean: '남자 아이', descriptionEnglish: 'Portrait of a boy'),
    Subcategory(nameKorean: '여자 아이', descriptionEnglish: 'Portrait of a girl'),
    Subcategory(nameKorean: '성인 남자', descriptionEnglish: 'Portrait of an adult man'),
    Subcategory(nameKorean: '성인 여자', descriptionEnglish: 'Portrait of an adult woman'),
    Subcategory(nameKorean: '남자 노인', descriptionEnglish: 'Portrait of an elderly man'),
    Subcategory(nameKorean: '여자 노인', descriptionEnglish: 'Portrait of an elderly woman'),
  ],
  '동물화': [
    Subcategory(nameKorean: '말', descriptionEnglish: 'Horse'),
    Subcategory(nameKorean: '새', descriptionEnglish: 'Bird'),
    Subcategory(nameKorean: '개', descriptionEnglish: 'Dog'),
    Subcategory(nameKorean: '소', descriptionEnglish: 'Cow'),
    Subcategory(nameKorean: '사자', descriptionEnglish: 'Lion'),
    Subcategory(nameKorean: '고양이', descriptionEnglish: 'Cat'),
    Subcategory(nameKorean: '양', descriptionEnglish: 'Sheep'),
  ],
};

enum ImageMode { blackAndWhite, color }

// Tag 클래스를 수정하여 Subcategory를 포함합니다.
class Tag {
  final String category;
  final Subcategory? subcategory;

  Tag({required this.category, this.subcategory});
}

class TestSketches extends StatelessWidget {
  const TestSketches({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchScreen(); // SearchScreen 호출
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textController = TextEditingController();
  ImageMode _imageMode = ImageMode.color;
  Tag? selectedTag;

  // 랜덤 서브카테고리 가져오기 함수
  Subcategory _getRandomSubcategory({String? category}) {
    final random = Random();
    if (category != null && categories.containsKey(category)) {
      final subcategories = categories[category]!;
      return subcategories[random.nextInt(subcategories.length)];
    } else {
      final allSubcategories = categories.values.expand((e) => e).toList();
      return allSubcategories[random.nextInt(allSubcategories.length)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(), // BaseAppBar는 appbar.dart에서 정의된 AppBar 위젯입니다.
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          _buildTextField(),
          if (selectedTag != null) _buildSelectedTag(),
          SizedBox(height: 20),
          _buildImageModeSelector(),
          SizedBox(height: 20),
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _textController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: selectedTag == null
              ? '생성할 이미지를 작성하세요'
              : '추가할 설명을 작성하세요',
          prefixIcon: IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () async {
              final tag = await Navigator.push<Tag>(
                context,
                MaterialPageRoute(
                  builder: (context) => TagSearchScreen(),
                ),
              );
              if (tag != null) {
                setState(() {
                  selectedTag = tag;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTag() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
      child: Row(
        children: [
          Text(
            '선택된 태그: ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Chip(
            label: Text(selectedTag!.subcategory?.nameKorean ?? selectedTag!.category),
            deleteIcon: Icon(Icons.close),
            onDeleted: () {
              setState(() {
                selectedTag = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageModeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('흑백'),
        Radio<ImageMode>(
          value: ImageMode.blackAndWhite,
          groupValue: _imageMode,
          onChanged: (value) {
            setState(() {
              _imageMode = value!;
            });
          },
        ),
        Text('컬러'),
        Radio<ImageMode>(
          value: ImageMode.color,
          groupValue: _imageMode,
          onChanged: (value) {
            setState(() {
              _imageMode = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _onGeneratePressed,
        child: Text('도안생성'),
      ),
    );
  }

  Future<void> _onGeneratePressed() async {
    String description = '';
    if (_textController.text.isEmpty) {
      if (selectedTag != null) {
        if (selectedTag!.subcategory != null) {
          description = selectedTag!.subcategory!.descriptionEnglish;
        } else {
          description =
              _getRandomSubcategory(category: selectedTag!.category).descriptionEnglish;
        }
      } else {
        description = _getRandomSubcategory().descriptionEnglish;
      }
    } else {
      final translatedText = await _translateText(_textController.text);
      if (selectedTag != null && selectedTag!.subcategory != null) {
        description =
        '${selectedTag!.subcategory!.descriptionEnglish}. $translatedText';
      } else {
        description = translatedText;
      }
    }
    _navigateToResultScreen(description);
  }

  void _navigateToResultScreen(String description) {
    final basePrompt =
        '$description in sketch style, drawn in a hand-drawn style.';
    final modeDescription = _imageMode == ImageMode.blackAndWhite
        ? 'The image should be in black and white, with no colors.'
        : 'The image should be in full color, with vivid and realistic colors.';
    final fullDescription = '$basePrompt $modeDescription';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(description: fullDescription),
      ),
    );
  }

  Future<String> _translateText(String text) async {
    //final Deepl_KEY // Deepl API 키를 입력하세요
    final url = Uri.parse('https://api-free.deepl.com/v2/translate');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'auth_key': Deepl_KEY,
          'text': text,
          'target_lang': 'EN',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translations'][0]['text'];
      } else {
        print('Deepl API 오류: ${response.body}');
        return text;
      }
    } catch (e) {
      print('Deepl API 예외 발생: $e');
      return text;
    }
  }
}

class TagSearchScreen extends StatelessWidget {
  const TagSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        Tag(category: category),
                      );
                    },
                    child: Text('아무거나'),
                  ),
                  ...categories[category]!.map((subcategory) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(
                          context,
                          Tag(category: category, subcategory: subcategory),
                        );
                      },
                      child: Text(
                        subcategory.nameKorean,
                        style: TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ],
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
    //final API_KEY_2 // OpenAI API 키를 입력하세요
    final url = Uri.parse('https://api.openai.com/v1/images/generations');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $API_KEY_2',
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
        if (data['data'] != null && data['data'].isNotEmpty) {
          setState(() {
            imageUrl = data['data'][0]['url'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          _showError('이미지를 생성하지 못했습니다.');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('이미지를 생성하지 못했습니다.');
      }
    } on TimeoutException {
      setState(() {
        isLoading = false;
      });
      _showError('요청이 시간 초과되었습니다.');
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showError('오류가 발생했습니다: $error');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _downloadImage(String url) async {
    try {
      if (await _requestPermission()) {
        final response = await Dio()
            .get(url, options: Options(responseType: ResponseType.bytes));

        final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 100,
          name: 'generated_image_${DateTime.now().millisecondsSinceEpoch}',
        );

        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이미지가 갤러리에 저장되었습니다.')),
          );
        } else {
          throw Exception('이미지 저장 실패');
        }
      } else {
        _showError('저장 권한이 필요합니다.');
      }
    } catch (e) {
      _showError('이미지를 저장하지 못했습니다: $e');
    }
  }

  Future<bool> _requestPermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
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
                  onPressed: imageUrl != null ? () => _downloadImage(imageUrl!) : null,
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
