import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../models/clevelandArtwork.dart';
import '../models/semaArtwork.dart';
import '../widgets/appbar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';
import 'artworkDescription.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:BaseAppBar(),
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          children: [
            Wrap(
                spacing: 5.0,
                children: List.generate(artGalleriesList.length,(index){
                  return ChoiceChip(
                    label: Text(artGalleriesList[index]),
                    backgroundColor: Color(0xffF0DFC8),
                    selectedColor: Color(0xFFC6BFA6),
                    selected: selectedArtGalleryIndex == index,
                    onSelected: (selected){
                      setState(() {
                        if(selected) {
                          selectedArtGalleryIndex = index;
                          if(selectedArtGalleryIndex == 0){
                            showSemaKeyword = true;
                            showClevelandKeyword = false;
                            showClevelandArtwork = false;
                            selectedClevelandKeywordIndex = null;
                          }else if(selectedArtGalleryIndex == 1){
                            showClevelandKeyword = true;
                            showSemaKeyword = false;
                            showSemaArtwork = false;
                            selectedSemaKeywordIndex = null;
                          }
                        }else{
                          selectedArtGalleryIndex = null;
                          selectedSemaKeywordIndex = null;
                          selectedClevelandKeywordIndex = null;
                          showSemaKeyword=false;
                          showClevelandKeyword=false;
                          showSemaArtwork=false;
                          showClevelandArtwork=false;
                        }
                      });
                    },
                  );
                })
            ),

            Divider(color: Colors.black, height: 3,),

            showSemaKeyword ? Wrap(
                spacing: 5.0,
                children: List.generate(semaKeywordsList.length,(index){
                  return ChoiceChip(
                    label: Text(semaKeywordsList[index]),
                    backgroundColor: Color(0xffF0DFC8),
                    selectedColor: Color(0xFFC6BFA6),
                    selected: selectedSemaKeywordIndex == index,
                    onSelected: (selected){
                      setState(() {
                        if(selected) {
                          selectedSemaKeywordIndex = index;
                          futureSemaArtwork=fetchSemaArtwork();
                          showSemaArtwork=true;
                        }else{
                          selectedSemaKeywordIndex = null;
                          showSemaArtwork=false;
                        }
                      });
                    },
                  );
                })
            ) : Container(),

            showClevelandKeyword ? Wrap(
                spacing: 5.0,
                children: List.generate(clevelandKeywordsList.length,(index){
                  return ChoiceChip(
                    label: Text(clevelandKeywordsList[index]),
                    backgroundColor: Color(0xffF0DFC8),
                    selectedColor: Color(0xFFC6BFA6),
                    selected: selectedClevelandKeywordIndex == index,
                    onSelected: (selected){
                      setState(() {
                        if(selected) {
                          selectedClevelandKeywordIndex = index;
                          futureClevelandArtwork=fetchClevelandArtwork();
                          showClevelandArtwork=true;
                        }else{
                          selectedClevelandKeywordIndex = null;
                          showClevelandArtwork=false;
                        }
                      });
                    },
                  );
                })
            ) : Container(),

            selectedArtGalleryIndex != null ? Divider(color: Colors.black, height: 3,) : Container(),

            showSemaArtwork ? Expanded(
                child: FutureBuilder<List<SemaArtwork>>(
                  future: futureSemaArtwork,
                  builder: (context, snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(),);
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData) {
                      return Text('No data');
                    } else {
                      return NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollEndNotification) {
                            final currentScrollOffset = notification.metrics.pixels;
                            final scrollSpeed = (currentScrollOffset - lastScrollOffset).abs();
                            if (notification.metrics.extentAfter == 0) {
                              if (scrollSpeed < 50) {
                                setState(() {
                                  futureSemaArtwork = fetchSemaArtwork();
                                });
                              }
                            }
                            lastScrollOffset = currentScrollOffset;
                          }
                          return true;
                        },
                        child: MasonryGridView.count(
                          padding: EdgeInsets.all(10),
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final imageUrl = snapshot.data![index].mainImage;
                            return GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => SemaArtworkDescription(semaArtwork: snapshot.data![index],)));
                                },
                                child: Image.network(
                                  imageUrl!,
                                  errorBuilder: (context, error, stackTrace){
                                    return Container();
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if(loadingProgress == null ) return child;
                                    return Container(height: 150,);
                                  },
                                )
                            );
                          },
                        ),
                      );
                    }
                  },
                )
            ) : Container(),

            showClevelandArtwork ? Expanded(
                child: FutureBuilder<List<ClevelandArtwork>>(
                  future: futureClevelandArtwork,
                  builder: (context, snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(),);
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData) {
                      return Text('No data');
                    } else {
                      return NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollEndNotification) {
                            final currentScrollOffset = notification.metrics.pixels;
                            final scrollSpeed = (currentScrollOffset - lastScrollOffset).abs();
                            if (notification.metrics.extentAfter == 0) {
                              if (scrollSpeed < 50) {
                                setState(() {
                                  futureClevelandArtwork = fetchClevelandArtwork();
                                });
                              }
                            }
                            lastScrollOffset = currentScrollOffset;
                          }
                          return true;
                        },
                        child: MasonryGridView.count(
                          padding: EdgeInsets.all(10),
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            Widget? ImageWidget;
                            if(snapshot.data![index].images == null) ImageWidget=Container();
                            else if(snapshot.data![index].images!.web == null) ImageWidget=Container();
                            else if(snapshot.data![index].images!.web!.url == null) ImageWidget=Container();
                            else ImageWidget = Image.network(
                                snapshot.data![index].images!.web!.url!,
                                errorBuilder: (context, error, stackTrace){
                                  return Container();
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if(loadingProgress == null) return child;
                                  return Container(
                                    height: 150,
                                  );
                                },
                              );
                            return GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ClevelandArtworkDescription(clevelandArtwork: snapshot.data![index],)));
                              },
                              child: ImageWidget,
                            );
                          },
                        ),
                      );
                    }
                  },
                )
            ) : Container(),
          ],
        ),
      ),
    );
  }
}
