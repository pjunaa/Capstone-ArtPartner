import 'package:artpartner001/constants/api_constants.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '../widgets/appbar.dart';
import 'artanalyze.dart';
import 'artgallery.dart';
import 'artimprove.dart';
import '../TestSketches.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: BaseAppBar(),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(screenHeight*0.01, screenHeight*0.02, screenHeight*0.01, screenHeight*0.01),
            child: CustomSlider(),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(screenHeight*0.02, 0, screenHeight*0.02, screenHeight*0.04),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SquareHomeButton(buttonText: '작품\n분석', page: ArtAnalyze(),),
                        SquareHomeButton(buttonText: '개선\n방법', page: ArtImprove(),),
                      ],
                    ),
                    LongHomeButton(buttonText: '연습용 도안', page: TestSketches(),),
                    LongHomeButton(buttonText: '미술관', page: ArtGallery(),),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedContainer extends StatelessWidget {
  const RoundedContainer({super.key, required this.widget});
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          height: screenHeight*0.39,
          color: Colors.white,
          child: widget,
        )
    );
  }
}

class Exhibition {
  final String imageUrl;
  final String linkUrl;

  Exhibition({required this.imageUrl, required this.linkUrl});
}

class CustomSlider extends StatefulWidget {
  const CustomSlider({super.key});

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  List<Exhibition> exhibitions = [];
  int activeIndex = 0;
  Future<List<Exhibition>>? futureExhibition;

  @override
  void initState() {
    super.initState();
    futureExhibition = fetchExhibition();
  }

  Future<List<Exhibition>> fetchExhibition() async {
    final response = await http.get(Uri.parse('$KCISA_URL?serviceKey=$KCISA_KEY&numOfRows=10&pageNo=1'));
    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);
      final Set<String> seenUrls = Set();
      final exhibitions = document.findAllElements('item').map((element) {
        final imageUrl = element.findElements('IMAGE_OBJECT').single.text;
        final linkUrl = element.findElements('URL').single.text;
        return Exhibition(imageUrl: imageUrl, linkUrl: linkUrl);
      }).where((exhibition) => seenUrls.add(exhibition.imageUrl) && seenUrls.add(exhibition.linkUrl)).toList();
      return exhibitions;
    } else {
      throw Exception('Failed to load exhibitions ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: FutureBuilder<List<Exhibition>>(
        future: futureExhibition,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return RoundedContainer(widget: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return RoundedContainer(widget: Center(child: Text('전시 정보를 불러올 수 없습니다.')));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return RoundedContainer(widget: Center(child: Text('전시 일정이 없습니다.')));
          } else {
            final exhibitions = snapshot.data!;
            return Container(
              child: Center(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    CarouselSlider.builder(
                      options: CarouselOptions(
                        initialPage: 0,
                        viewportFraction: 1,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        height: screenHeight*0.39,
                        onPageChanged: (index, reason){
                          setState(() {
                            activeIndex = index;
                          });
                        },
                      ),
                      itemCount: exhibitions.length,
                      itemBuilder: (context, index, realIndex) {
                        final item = exhibitions[index];
                        return GestureDetector(
                            onTap: () async {
                              if (await canLaunch(item.linkUrl)) {
                                await launch(item.linkUrl);
                              } else {
                                throw 'Could not launch ${item.linkUrl}';
                              }
                            },
                            child: RoundedContainer(
                              widget: Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Container();
                                  }
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(child: Text('이미지 로딩 오류가 발생했습니다.'));
                                },
                              ),
                            )
                        );
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      alignment: Alignment.bottomCenter,
                      child: AnimatedSmoothIndicator(
                        activeIndex: activeIndex,
                        count: exhibitions.length,
                        effect: JumpingDotEffect(
                          dotHeight: 6,
                          dotWidth: 6,
                          activeDotColor: Colors.white,
                          dotColor: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class SquareHomeButton extends StatelessWidget {
  String buttonText;
  Widget page;
  SquareHomeButton({super.key, required this.buttonText, required this.page});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return TextButton(
      onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Text(buttonText, style: TextStyle(fontSize:screenHeight*0.025, fontWeight: FontWeight.w900, color: Colors.black)),
      style: TextButton.styleFrom(
          backgroundColor: Color(0xFFC6BFA6),
          minimumSize: Size(screenHeight*0.16, screenHeight*0.13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
      ),
    );
  }
}

class LongHomeButton extends StatelessWidget {
  String buttonText;
  Widget page;
  LongHomeButton({super.key, required this.buttonText, required this.page});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return TextButton(
      onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Text(buttonText, style: TextStyle(fontSize:screenHeight*0.025, fontWeight: FontWeight.w900, color: Colors.black)),
      style: TextButton.styleFrom(
          backgroundColor: Color(0xFFC6BFA6),
          minimumSize: Size(screenHeight*0.35, screenHeight*0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
      ),
    );
  }
}