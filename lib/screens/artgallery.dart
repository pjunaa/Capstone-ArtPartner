import 'package:artpartner001/screens/artSearch.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../models/clevelandArtwork.dart';
import '../models/semaArtwork.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import '../utils/artworkDisplay.dart';


class ArtGalleryAppBar extends StatelessWidget implements PreferredSizeWidget{
  const ArtGalleryAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Column(
        children: [
          Image.asset('assets/images/logo.png', height: 55,),
          SizedBox(height: 5)
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, size: 35),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ArtSearch()));
          },
        )
      ],
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.0);
}

class CustomChoiceChips extends StatelessWidget {
  CustomChoiceChips({required this.keywords, required this.selectedIndex, required this.onSelected,});
  final List<String> keywords;
  final int? selectedIndex;
  final Function(int, bool) onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5.0,
      children: List.generate(keywords.length, (index) {
        return ChoiceChip(
          label: Text(keywords[index]),
          backgroundColor: Color(0xffF0DFC8),
          selectedColor: Color(0xFFC6BFA6),
          selected: selectedIndex == index,
          onSelected: (selected) => onSelected(index, selected),
        );
      }),
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Colors.black,
      height: 3,
    );
  }
}

class MessageText extends StatelessWidget {
  const MessageText({super.key, required this.text,});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 5),
        Text(text,)
      ],
    );
  }
}

class ArtGallery extends StatefulWidget {
  const ArtGallery({super.key});

  @override
  State<ArtGallery> createState() => _ArtGalleryState();
}

class _ArtGalleryState extends State<ArtGallery> {
  Future<List<SemaArtwork>>? futureSemaArtwork;
  Future<List<ClevelandArtwork>>? futureClevelandArtwork;
  int? selectedArtGalleryIndex;
  int? selectedSemaKeywordIndex;
  int? selectedClevelandKeywordIndex;
  List<String> artGalleriesList = ['서울시립미술관', 'Cleveland Museum of Art'];
  List<String> semaKeywordsList = ['공예', '뉴미디어', '드로잉&판화', '디자인', '사진', '설치', '조각', '한국화', '회화'];
  List<String> clevelandKeywordsList = ['드로잉', '사진', '회화', '포트폴리오', '초상화', '판화', '조각', '직물'];
  List<String> clevelandKeywordsList_fetch = ['Drawing', 'Photograph', 'Painting', 'Portfolio', 'Portrait Miniature', 'Print', 'Sculpture', 'Textile'];
  bool showSemaKeyword = false;
  bool showClevelandKeyword = false;
  bool showSemaArtwork = false;
  bool showClevelandArtwork = false;
  double lastScrollOffset = 0;

  Future<List<SemaArtwork>> fetchSemaArtwork() async{
    String prdctNmKorean = semaKeywordsList[selectedSemaKeywordIndex!];
    int startIndex=1;
    int endIndex= 1;

    final response1 = await http.get(
        Uri.parse('$SEMA_URL/$SEMA_KEY/json/SemaPsgudInfoKorInfo/$startIndex/$endIndex/$prdctNmKorean')
    );
    if(response1.statusCode==200){
      int max =(jsonDecode(response1.body)['SemaPsgudInfoKorInfo']['list_total_count'] ?? []) as int;
      startIndex = 1 + Random().nextInt(max-19);
      endIndex=startIndex+19;
    }else{
      throw Exception('Failed to load album');
    }

    final response2 = await http.get(
        Uri.parse('$SEMA_URL/$SEMA_KEY/json/SemaPsgudInfoKorInfo/$startIndex/$endIndex/$prdctNmKorean')
    );
    if(response2.statusCode==200){
      return((jsonDecode(response2.body)['SemaPsgudInfoKorInfo']['row'] ?? []) as List)
          .map((e)=>SemaArtwork.fromJson(e))
          .toList();
    }else{
      throw Exception('Failed to load album');
    }
  }

  Future<List<ClevelandArtwork>> fetchClevelandArtwork() async{
    String type = clevelandKeywordsList_fetch[selectedClevelandKeywordIndex!];
    int skip = 0;
    int limit = 20;

    final response1 = await http.get(
        Uri.parse('$CLEVELAND_URL/api/artworks/?type=$type&skip=$skip&limit=1&has_image=1&fields=id')
    );
    if(response1.statusCode==200){
      int max =(jsonDecode(response1.body)['info']['total'] ?? []) as int;
      if(max<20){
        skip=0;
        limit=max;
      }else{
        skip = Random().nextInt(max-19);
      }
    }else{
      throw Exception('Failed to load album');
    }

    final response2 = await http.get(
        Uri.parse('$CLEVELAND_URL/api/artworks/?type=$type&skip=$skip&limit=$limit&has_image=1')
    );
    if(response2.statusCode==200){
      return((jsonDecode(response2.body)['data'] ?? []) as List)
          .map((e)=>ClevelandArtwork.fromJson(e))
          .toList();
    }else{
      throw Exception('Failed to load album');
    }
  }

  void onArtGallerySelected(int index, bool selected) {
    setState(() {
      if (selected) {
        selectedArtGalleryIndex = index;
        if (index == 0) {
          showSemaKeyword = true;
          showClevelandKeyword = false;
          showClevelandArtwork = false;
          selectedClevelandKeywordIndex = null;
        } else if (index == 1) {
          showClevelandKeyword = true;
          showSemaKeyword = false;
          showSemaArtwork = false;
          selectedSemaKeywordIndex = null;
        }
      } else {
        selectedArtGalleryIndex = null;
        selectedSemaKeywordIndex = null;
        selectedClevelandKeywordIndex = null;
        showSemaKeyword = false;
        showClevelandKeyword = false;
        showSemaArtwork = false;
        showClevelandArtwork = false;
      }
    });
  }

  void onSemaKeywordSelected(int index, bool selected) {
    setState(() {
      if (selected) {
        selectedSemaKeywordIndex = index;
        futureSemaArtwork = fetchSemaArtwork();
        showSemaArtwork = true;
      } else {
        selectedSemaKeywordIndex = null;
        showSemaArtwork = false;
      }
    });
  }

  void onClevelandKeywordSelected(int index, bool selected) {
    setState(() {
      if (selected) {
        selectedClevelandKeywordIndex = index;
        futureClevelandArtwork = fetchClevelandArtwork();
        showClevelandArtwork = true;
      } else {
        selectedClevelandKeywordIndex = null;
        showClevelandArtwork = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:ArtGalleryAppBar(),
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          children: [
            CustomChoiceChips(
              keywords: artGalleriesList,
              selectedIndex: selectedArtGalleryIndex,
              onSelected: onArtGallerySelected,
            ),
            CustomDivider(),

            if(showSemaKeyword)
              CustomChoiceChips(
                keywords: semaKeywordsList,
                selectedIndex: selectedSemaKeywordIndex,
                onSelected: onSemaKeywordSelected,
              ),
            if(showClevelandKeyword)
              CustomChoiceChips(
                keywords: clevelandKeywordsList,
                selectedIndex: selectedClevelandKeywordIndex,
                onSelected: onClevelandKeywordSelected,
              ),
            if(selectedArtGalleryIndex != null)
              CustomDivider(),
            if(!showSemaKeyword && !showClevelandKeyword)
              MessageText(text: '미술관을 선택해주세요.'),

            if(showSemaArtwork)
              ArtworkGridView<SemaArtwork>(
                futureArtwork: futureSemaArtwork,
                fetchMoreArtwork: () {
                  setState(() {
                    futureSemaArtwork = fetchSemaArtwork();
                  });
                },
                lastScrollOffset: lastScrollOffset,
                imageUrlExtractor: (artwork) => artwork.mainImage ?? '',
                showLoadMore: true,
              ),
            if(showClevelandArtwork)
              ArtworkGridView<ClevelandArtwork>(
                futureArtwork: futureClevelandArtwork,
                fetchMoreArtwork: () {
                  setState(() {
                    futureClevelandArtwork = fetchClevelandArtwork();
                  });
                },
                lastScrollOffset: lastScrollOffset,
                imageUrlExtractor: (artwork) => artwork.images?.web?.url ?? '',
                showLoadMore: true,
              ),
            if((showSemaKeyword || showClevelandKeyword) && !showSemaArtwork && !showClevelandArtwork)
              MessageText(text: '키워드를 선택해주세요.'),
          ],
        ),
      ),
    );
  }
}
