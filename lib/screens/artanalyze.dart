import 'dart:io';
import 'dart:typed_data';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../utils/timerProvider.dart';

import '../services/analyze_api_service.dart';

import 'history.dart';

class ArtAnalyze extends StatefulWidget {
  const ArtAnalyze({super.key});

  @override
  State<ArtAnalyze> createState() => _MyArtAnalyzeState();
}

class _MyArtAnalyzeState extends State<ArtAnalyze> {
  final apiService = ApiService();
  File? _selectedImage;
  String nameCheck = '';
  String gptResult = '';
  bool detecting = false;
  bool resultLoading = false;
  Box analyzeBox = Hive.box("analyzeHistory");
  Uint8List? ImageBytes;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile =
    await ImagePicker().pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      if(_selectedImage != null){
        ImageBytes = await _selectedImage!.readAsBytes();
      }
      gptResult='';
    }
  }

  /*
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
  }*/

  showResult() async {
    setState(() {
      resultLoading = true;
    });
    try {
      if (gptResult == '') {
        gptResult =
        await apiService.sendImageToGPT4Vision_2(image: _selectedImage!);
        // apiService.sendMessageGPT(nameCheck: nameCheck); | GPT3.5 분석답변을 GPT4Vision으로 변경

        // gptResult = 'gptResult' + DateTime.now().millisecondsSinceEpoch.toString()+'\n이 그림은 다음과 같은 기법을 사용하여 정경을 생동감 있게 표현한 작은 집을 그리고 있습니다:\n1. 질감: 건조 브러쉬 기법처럼 보이는 두꺼운 페인트 사용은 잔디와 집에 질감을 주어 손으로 만질 수 있는, 거칠고 자연스러운 느낌을 줍니다.\n2. 색상 그라데이션: 하늘은 따뜻한 보라색에서 시원한 파란색으로 부드럽게 전환되어 평온하고 차분한 분위기를 만들어냅니다.\n3. 구성: 집은 중심에서 벗어나 있으며, 삼분법을 따라 자연스럽고 미적으로 즐거운 경치를 제공합니다.\n4. 색상 대비: 주변 배경의 절제된 색상과 대비되는 집 의 선명한 빨간색 문은 중심 지점으로 시선을 끌어냅니다.\n5. 원근법: 집으로 이어지는 길에는 원근법이 시도되고 있지만, 깊이의 느낌을 강화하기 위해 좀 더 의도적인 소실점을 사용하면 도움이 될 것입니다.';

        analyzeBox.put(
          DateTime.now().millisecondsSinceEpoch.toString(),
          {
            'image': ImageBytes,
            'text': gptResult
          }
        );
      }
      _showSuccessDialog(gptResult);
    } catch (error) {
      _showErrorSnackBar(error);
    } finally {
      setState(() {
        resultLoading = false;
      });
    }
  }

  void _showErrorSnackBar(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error.toString()),
      backgroundColor: Colors.red,
    ));
  }

  void _showSuccessDialog(String content) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '분석 결과',
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 여백
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
          textAlign: TextAlign.left, // 왼쪽 정렬
        ),
      ),
      btnOkText: '확인',
      btnOkOnPress: () {},
      btnOkColor: const Color(0xFFBBAF96),
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyzeHistory()));
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
            child: Image.asset('assets/images/pick1.png'),
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
                      // 타이머가 완료되었을 경우 결과 페이지
                      timerProvider.startTimer();
                      showResult();
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
                    '분석 결과',
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
