import 'dart:convert';

import 'package:artpartner001/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/clevelandArtwork.dart';
import '../services/google_translate.dart';
import '../utils/artworkDisplay.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key, required this.onPressed, required this.controller});
  final Function() onPressed;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Cleveland Museum of Art의 미술작품 검색",
                      hintStyle: TextStyle(color: Colors.black38)
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: onPressed,
              ),
            ],
          ),
          Divider(height: 1, color: Colors.black,),
        ],
      ),
    );
  }
}

class ArtSearch extends StatefulWidget {
  const ArtSearch({super.key});

  @override
  State<ArtSearch> createState() => _ArtSearchState();
}

class _ArtSearchState extends State<ArtSearch> {
  Future<List<ClevelandArtwork>>? futureSearchedArtwork;
  TextEditingController searchController = TextEditingController();
  double lastScrollOffset = 0;
  int skip = 0;
  int limit = 20;
  String? query;
  int max = 0;
  bool showLoadMore = false;

  Future<List<ClevelandArtwork>> searchClevelandArtwork() async{
    final response = await http.get(
        Uri.parse('$CLEVELAND_URL/api/artworks/?q=$query&has_image=1&skip=$skip&limit=$limit')
    );
    if(response.statusCode==200){
      max =(jsonDecode(response.body)['info']['total'] ?? []) as int;
      return((jsonDecode(response.body)['data'] ?? []) as List)
          .map((e)=>ClevelandArtwork.fromJson(e))
          .toList();
    }else{
      throw Exception('Failed to load album');
    }
  }

  void _showEmptySearchAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('경고'),
          content: Text('검색어를 입력해주세요.'),
          actions: [
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

  bool isEnglish(String input) {
    final englishRegex = RegExp(r"^[a-zA-Z0-9\s~!@#$%^&*()_\-+=\\|;:\[\]{}<>,./?']+$");
    return englishRegex.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(),
      body: Column(
        children: [
          CustomSearchBar(
            controller: searchController,
            onPressed: () async {
              if (searchController.text.trim().isEmpty) {
                _showEmptySearchAlert(context);
              } else {
                setState(() {
                  skip = 0;
                });

                if (isEnglish(searchController.text)) {
                  query = searchController.text;
                } else {
                  GoogleTranslate.initialize(
                    apiKey: GOOGLETRANS_KEY,
                    targetLanguage: "en",
                  );
                  query = await searchController.text.translate();
                }

                futureSearchedArtwork = searchClevelandArtwork().then((result) {
                  setState(() {
                    showLoadMore = skip + limit < max;
                  });
                  return result;
                });
              }
            },
          ),
          ArtworkGridView<ClevelandArtwork>(
            futureArtwork: futureSearchedArtwork,
            fetchMoreArtwork: () {
              if (skip + limit <= max) {
                setState(() {
                  skip += limit;
                  futureSearchedArtwork = searchClevelandArtwork();
                  showLoadMore = skip + limit < max;
                });
              }
            },
            lastScrollOffset: lastScrollOffset,
            imageUrlExtractor: (artwork) => artwork.images?.web?.url ?? '',
            showLoadMore: showLoadMore,
          )
        ],
      ),
    );
  }
}
