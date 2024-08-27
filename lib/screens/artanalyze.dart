import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';

import '../services/analyze_api_service.dart';

import '../widgets/appbar.dart';

class ArtAnalyze extends StatefulWidget {
  const ArtAnalyze({super.key});

  @override
  State<ArtAnalyze> createState() => _MyArtAnalyzeState();
}

class _MyArtAnalyzeState extends State<ArtAnalyze> {
  final apiService = ApiService();
  File? _selectedImage;
  String nameCheck = '';  // 이전 diseaseName
  String gptResult = '';
  bool detecting = false;
  bool resultLoading = false;

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

  showResult() async {
    setState(() {
      resultLoading = true;
    });
    try {
      if (gptResult == '') {
        gptResult =
        await apiService.sendImageToGPT4Vision(image: _selectedImage!);
        // apiService.sendMessageGPT(nameCheck: nameCheck); | GPT3.5 분석답변을 GPT4Vision으로 변경
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
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: '분석 결과',
      desc: content,
      btnOkText: '확인',
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:BaseAppBar(),
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
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  onPressed: () {
                    showResult();
                  },
                  child: Text(
                    '분석 결과',
                    style: TextStyle(
                      color: Colors.white, // Set the text color to white
                      fontSize: 16, // Set the font size
                      fontWeight:
                      FontWeight.bold, // Set the font weight to bold
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
