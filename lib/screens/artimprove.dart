import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../utils/timerProvider.dart';
import '../services/improve_api_service.dart';

import '../screens/artimprove_result.dart';
import 'history.dart';

class ArtImprove extends StatefulWidget {
  const ArtImprove({super.key});

  @override
  State<ArtImprove> createState() => _MyArtImproveState();
}

class _MyArtImproveState extends State<ArtImprove> {
  final apiService = ApiService();
  File? _selectedImage;
  String nameCheck = '';  // 이전 diseaseName
  String gptResult = '';
  bool detecting = false;
  bool resultLoading = false;
  Box improveBox = Hive.box("improveHistory");

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile =
    await ImagePicker().pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  detectDisease() async {
    setState(() {
      detecting = true;
    });
    try {
      nameCheck =
      'pass';
    } catch (error) {
      _showErrorSnackBar(error);
    } finally {
      setState(() {
        detecting = false;
      });
    }
  }


  void _showErrorSnackBar(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error.toString()),
      backgroundColor: Colors.red,
    ));
  }


  void _goToResultPage() {
    if (_selectedImage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArtImproveResult(selectedImage: _selectedImage),
        ),
      );
    } else {
      // 이미지가 선택되지 않았을 때 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지를 선택해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Column(
          children: [
            Image.asset('assets/images/logo.png', height: 55,),
            SizedBox(height: 5)
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ImproveHistory()));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '지난 기록',
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.history,
                )
              ],
            ),
          )
        ],
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.23,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    // Top right corner
                    bottomLeft: Radius.circular(50.0), // Bottom right corner
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        _pickImage(ImageSource.gallery);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'OPEN GALLERY',
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.image,
                          )
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _pickImage(ImageSource.camera);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('START CAMERA'),
                          const SizedBox(width: 10),
                          Icon(Icons.camera_alt)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _selectedImage == null
              ? Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Image.asset('assets/images/pick2.png'),
          )
              : Expanded(
            child: Container(
              width: double.infinity,
              decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          if (_selectedImage != null)
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DefaultTextStyle(
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                        child: AnimatedTextKit(
                            isRepeatingAnimation: false,
                            repeatForever: false,
                            displayFullTextOnTap: true,
                            totalRepeatCount: 1,
                            animatedTexts: [
                              TyperAnimatedText(
                                nameCheck.trim(),
                              ),
                            ]),
                      )
                    ],
                  ),
                ),
                resultLoading
                    ? const SpinKitWave(
                  color: Colors.blue,
                  size: 30,
                )
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFC6BFA6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  onPressed: () {
                    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
                    if (timerProvider.timerCompleted) {
                      // 타이머가 완료되었을 경우 결과 페이지 이동
                      timerProvider.startTimer();
                      _goToResultPage();
                    } else {
                      // 타이머가 완료되지 않았을 경우 경고 메시지 표시
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('과도한 요청 발생. 잠시 후 다시 시도해주세요.'),
                        ),
                      );
                    }
                  },
                  child: Text(
                    '개선 방법 검색',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
