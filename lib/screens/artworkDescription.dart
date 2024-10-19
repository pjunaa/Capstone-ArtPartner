import 'package:artpartner001/screens/semaSource.dart';

import '../services/google_translate.dart';
import '../utils/artworkDisplay.dart';
import '../widgets/appbar.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../models/clevelandArtwork.dart';
import '../models/semaArtwork.dart';

class SemaDescriptionAppBar extends StatelessWidget implements PreferredSizeWidget{
  const SemaDescriptionAppBar({super.key});

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
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => SemaSource()));
          },
          icon: Icon(Icons.copyright, size: 35,),)
      ],
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.0);
}

class ArtworkTitle extends StatelessWidget {
  const ArtworkTitle({super.key, required this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    if(text != null){
      return Text(
        text!,
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      );
    }else{
      return Container();
    }
  }
}

class ArtworkSubTitle extends StatelessWidget {
  const ArtworkSubTitle({super.key, required this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    if(text != null){
      return Text(
        text!,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      );
    }else{
      return Container();
    }
  }
}

class SemaText extends StatelessWidget {
  const SemaText({super.key, required this.title, required this.text});
  final String title;
  final String? text;

  @override
  Widget build(BuildContext context) {
    if(text != null && text != ''){
      return Text(
        '$title: $text',
        style: TextStyle(fontSize: 20,),
        textAlign: TextAlign.center,
      );
    }else{
      return Container();
    }
  }
}

class ClevelandText extends StatelessWidget {
  const ClevelandText({super.key, required this.title, required this.text});
  final String title;
  final String? text;

  @override
  Widget build(BuildContext context) {
    if(text != null && text != ''){
      return Text(
        '$title: $text',
        style: TextStyle(fontSize: 20,),
      );
    }else{
      return Container();
    }
  }
}

class ClevelandListText extends StatelessWidget {
  const ClevelandListText({super.key, required this.title, required this.textList});
  final String title;
  final List? textList;

  @override
  Widget build(BuildContext context) {
    String text;

    if(textList != null){
      text=textList!.join(', ');
      if(text != null && text != ''){
        return Text(
          '$title: $text',
          style: TextStyle(fontSize: 20,),
        );
      }
    }
    return Container();
  }
}

class SemaArtworkDescription extends StatelessWidget {
  SemaArtwork semaArtwork;
  SemaArtworkDescription({super.key, required this.semaArtwork});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: SemaDescriptionAppBar(),
        body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ImageAndButtons(imageUrl: semaArtwork.mainImage),
                SizedBox(height: 20,),
                semaArtwork.prdctNmKorean! == semaArtwork.prdctNmEng! ? ArtworkTitle(text: semaArtwork.prdctNmKorean,) : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ArtworkTitle(text: semaArtwork.prdctNmKorean,),
                    ArtworkSubTitle(text: semaArtwork.prdctNmEng,)
                  ],
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: EdgeInsets.fromLTRB(15,0,15,0),
                  child: Column(
                    children: [
                      SemaText(title: '제작년도', text: semaArtwork.mnfctYear),
                      SemaText(title: '작가명', text: semaArtwork.writrNm),
                      SemaText(title: '부문', text: semaArtwork.prdctClNm),
                      SemaText(title: '작품규격', text: semaArtwork.prdctStndrd),
                      SemaText(title: '재료/기법', text: semaArtwork.matrlTechnic),
                      SemaText(title: '작품해설', text: semaArtwork.prdctDetail),
                    ],
                  ),
                ),
                SizedBox(height: 40,),
              ],
            )
        )
    );
  }
}

class ClevelandArtworkDescription extends StatefulWidget {
  ClevelandArtwork clevelandArtwork;
  ClevelandArtworkDescription({super.key, required this.clevelandArtwork});

  @override
  State<ClevelandArtworkDescription> createState() => _ClevelandArtworkDescriptionState();
}

class _ClevelandArtworkDescriptionState extends State<ClevelandArtworkDescription> {
  String? imageUrl;
  List<String>? creatorsDescription;
  late ClevelandArtwork translatedArtwork;
  List<String>? translatedCreatorsDescription;
  bool showTranslated = false;
  bool translated = false;
  String translateButtonText = '번역 보기';
  bool isLoading = false;

  String removeHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, ' ');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    imageUrl = widget.clevelandArtwork.images?.web?.url ?? null;

    creatorsDescription = widget.clevelandArtwork.creators?.isEmpty ?? true
        ? null
        : widget.clevelandArtwork.creators!
        .map((creator) => creator.description ?? '')
        .toList();

    if(widget.clevelandArtwork.description != null){
      widget.clevelandArtwork.description = removeHtmlTags(widget.clevelandArtwork.description!);
    }

    if(widget.clevelandArtwork.culture != null){
      if(widget.clevelandArtwork.culture!.isEmpty){
        widget.clevelandArtwork.culture = null;
      }
    }
  }

  void translate() async {
    setState(() {
      isLoading = true;
    });

    translatedArtwork = ClevelandArtwork.clone(widget.clevelandArtwork);
    translatedCreatorsDescription = creatorsDescription;

    GoogleTranslate.initialize(
      apiKey: GOOGLETRANS_KEY,
      targetLanguage: "ko",
    );

    if (widget.clevelandArtwork.title != null) {
      translatedArtwork.title = await widget.clevelandArtwork.title!.translate();
    }

    if (widget.clevelandArtwork.creationDate != null) {
      translatedArtwork.creationDate = await widget.clevelandArtwork.creationDate!.translate();
    }

    if (creatorsDescription != null) {
      translatedCreatorsDescription = [];
      for (final creator in creatorsDescription!) {
        if (creator != null) {
          final translatedCreator = await creator.translate();
          translatedCreatorsDescription!.add(translatedCreator);
        }
      }
    } else {
      translatedCreatorsDescription = null;
    }

    if (widget.clevelandArtwork.department != null) {
      translatedArtwork.department = await widget.clevelandArtwork.department!.translate();
    }

    if (widget.clevelandArtwork.type != null) {
      translatedArtwork.type = await widget.clevelandArtwork.type!.translate();
    }

    if (widget.clevelandArtwork.culture != null) {
      translatedArtwork.culture = [];
      for (final culture in widget.clevelandArtwork.culture!) {
        if (culture != null) {
          final translatedCulture = await culture.translate();
          translatedArtwork.culture!.add(translatedCulture);
        }
      }
    } else {
      translatedArtwork.culture = null;
    }

    if (widget.clevelandArtwork.measurements != null) {
      translatedArtwork.measurements = await widget.clevelandArtwork.measurements!.translate();
    }

    if (widget.clevelandArtwork.technique != null) {
      translatedArtwork.technique = await widget.clevelandArtwork.technique!.translate();
    }

    if (widget.clevelandArtwork.series != null) {
      translatedArtwork.series = await widget.clevelandArtwork.series!.translate();
    }

    if (widget.clevelandArtwork.description != null) {
      translatedArtwork.description = await widget.clevelandArtwork.description!.translate();
    }

    setState(() {
      isLoading = false;
      translated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BaseAppBar(),
        body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImageAndButtons(imageUrl: imageUrl,),
                if(isLoading)
                  Container(
                      height: 300,
                      child: Center(child: CircularProgressIndicator())
                  ),
                if(!isLoading && !showTranslated)
                  Column(
                    children: [
                      SizedBox(height: 20,),
                      ArtworkTitle(text: widget.clevelandArtwork.title,),
                      SizedBox(height: 20,),
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClevelandText(title: '제작일', text: widget.clevelandArtwork.creationDate),
                            ClevelandListText(title: '창작자', textList: creatorsDescription),
                            ClevelandText(title: '부문', text: widget.clevelandArtwork.department),
                            ClevelandText(title: '유형', text: widget.clevelandArtwork.type),
                            ClevelandListText(title: '문화', textList: widget.clevelandArtwork.culture),
                            ClevelandText(title: '크기', text: widget.clevelandArtwork.measurements),
                            ClevelandText(title: '재료/기법', text: widget.clevelandArtwork.technique),
                            ClevelandText(title: '시리즈', text: widget.clevelandArtwork.series),
                            ClevelandText(title: '설명', text: widget.clevelandArtwork.description),
                          ],
                        ),
                      ),
                    ],
                  ),
                if(!isLoading && showTranslated)
                  Column(
                    children: [
                      SizedBox(height: 20,),
                      ArtworkTitle(text: translatedArtwork.title,),
                      SizedBox(height: 20,),
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClevelandText(title: '제작일', text: translatedArtwork.creationDate),
                            ClevelandListText(title: '창작자', textList: translatedCreatorsDescription),
                            ClevelandText(title: '부문', text: translatedArtwork.department),
                            ClevelandText(title: '유형', text: translatedArtwork.type),
                            ClevelandListText(title: '문화', textList: translatedArtwork.culture),
                            ClevelandText(title: '크기', text: translatedArtwork.measurements),
                            ClevelandText(title: '재료/기법', text: translatedArtwork.technique),
                            ClevelandText(title: '시리즈', text: translatedArtwork.series),
                            ClevelandText(title: '설명', text: translatedArtwork.description),
                          ],
                        ),
                      ),
                    ],
                  ),
                Center(
                  child: TextButton(
                    child:Text(translateButtonText, style: TextStyle(fontSize: 16)),
                    onPressed: (){
                      if(!translated) translate();
                      if(showTranslated){
                        setState(() {
                          showTranslated=false;
                          translateButtonText='번역 보기';
                        });
                      }else{
                        setState(() {
                          showTranslated=true;
                          translateButtonText='원문 보기';
                        });
                      }

                    },
                  ),
                ),
                SizedBox(height: 40,)
              ],
            )
        )
    );
  }
}