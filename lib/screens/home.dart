import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import 'artanalyze.dart';
import 'artgallery.dart';
import 'artimprove.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 30, 30, 100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              HomeButton(buttonText: '작품 분석', page: ArtAnalyze(),),
              HomeButton(buttonText: '개선 방법', page: ArtImprove(),),
              HomeButton(buttonText: '연습용 도안', page: TestSketches(),),
              HomeButton(buttonText: '미술관', page: ArtGallery(),),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  String buttonText;
  Widget page;
  HomeButton({super.key, required this.buttonText, required this.page});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Text(buttonText, style: TextStyle(fontSize:20, fontWeight: FontWeight.w900, color: Colors.black)),
      style: TextButton.styleFrom(
          backgroundColor: Color(0xFFC6BFA6),
          minimumSize: Size(300, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
      ),
    );
  }
}



class TestSketches extends StatelessWidget {
  const TestSketches({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar:BaseAppBar(), body: Center(child: Text('연습용 도안')),);
  }
}
