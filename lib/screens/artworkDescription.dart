import 'package:artpartner001/screens/semaSource.dart';

import '../services/google_translate.dart';
import '../utils/downloadImage.dart';
import '../widgets/appbar.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../models/clevelandArtwork.dart';
import '../models/semaArtwork.dart';
import 'fullScreenView.dart';

class SemaArtworkDescription extends StatelessWidget {
  SemaArtwork semaArtwork;
  SemaArtworkDescription({super.key, required this.semaArtwork});

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
            IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => SemaSource()));
              },
              icon: Icon(Icons.copyright, size: 35,),)
          ],
          scrolledUnderElevation: 0,
        ),
        body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Image.network(semaArtwork.mainImage!, width: double.infinity, fit: BoxFit.fitWidth,),
                    Positioned(
                      child: IconButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenView(imageUrl: semaArtwork.mainImage!,)));
                        },
                        icon: Icon(Icons.fullscreen, color: Colors.white,),
                        iconSize: 30,
                      ),
                      right: 0,
                      bottom: 0,
                    ),
                    Positioned(
                      child: IconButton(
                        onPressed: () async{
                          downloadImage(context, semaArtwork.mainImage!);
                        },
                        icon: Icon(Icons.download, color: Colors.white,),
                        iconSize: 30,
                      ),
                      right: 50,
                      bottom: 0,
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                semaArtwork.prdctNmKorean! == semaArtwork.prdctNmEng! ? Text(
                  semaArtwork.prdctNmKorean!, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center,
                ) : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(semaArtwork.prdctNmKorean!, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                    Text(semaArtwork.prdctNmEng!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                  ],
                ),
                SizedBox(height: 20,),
                Text('제작년도: ${semaArtwork.mnfctYear!}', style: TextStyle(fontSize: 20,), textAlign: TextAlign.center,),
                Text('작가명: ${semaArtwork.writrNm!}', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                Text('부문: ${semaArtwork.prdctClNm!}', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                Text('작품규격: ${semaArtwork.prdctStndrd!}', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                Text('재료/기법: ${semaArtwork.matrlTechnic!}', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                semaArtwork.prdctDetail != '' ? Text('작품해설: ${semaArtwork.prdctDetail}', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,) : Container(),
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

  String removeHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, ' ');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(widget.clevelandArtwork.images == null) imageUrl=null;
    else if(widget.clevelandArtwork.images!.web == null) imageUrl=null;
    else if(widget.clevelandArtwork.images!.web!.url == null) imageUrl=null;
    else imageUrl=widget.clevelandArtwork.images!.web!.url!;

    if(widget.clevelandArtwork.creators == null){
      creatorsDescription = null;
    }else if(widget.clevelandArtwork.creators!.isEmpty){
      creatorsDescription = null;
    }else{
      for(final creator in widget.clevelandArtwork.creators!){
        creatorsDescription = [];
        if(creator.description != null){
          creatorsDescription!.add(creator.description!);

        }else{
          creatorsDescription!.add('');
        }
      }
    }

    if(widget.clevelandArtwork.description != null){
      widget.clevelandArtwork.description = removeHtmlTags(widget.clevelandArtwork.description!);
    }

    if(widget.clevelandArtwork.culture != null){
      if(widget.clevelandArtwork.culture!.isEmpty){
        widget.clevelandArtwork.culture = null;
      }
    }
  }

  void translate(){
    translatedArtwork = ClevelandArtwork.clone(widget.clevelandArtwork);
    translatedCreatorsDescription = creatorsDescription;

    GoogleTranslate.initialize(
      apiKey: GOOGLETRANS_KEY,
      targetLanguage: "ko",
    );

    widget.clevelandArtwork.title != null ? widget.clevelandArtwork.title!.translate().then((value){
      setState(() {
        translatedArtwork.title = value;
      });
    }) : null;

    widget.clevelandArtwork.creationDate != null ? widget.clevelandArtwork.creationDate!.translate().then((value){
      setState(() {
        translatedArtwork.creationDate = value;
      });
    }) : null;

    if(creatorsDescription != null){
      translatedCreatorsDescription = [];
      for(final creator in creatorsDescription!){
        if(creator != null){
          creator.translate().then((value){
            setState(() {
              translatedCreatorsDescription!.add(value);
            });
          });
        }else translatedCreatorsDescription = null;
      }
    }else translatedCreatorsDescription = null;


    widget.clevelandArtwork.department != null ? widget.clevelandArtwork.department!.translate().then((value){
      setState(() {
        translatedArtwork.department = value;
      });
    }) : null;

    widget.clevelandArtwork.type != null ? widget.clevelandArtwork.type!.translate().then((value){
      setState(() {
        translatedArtwork.type = value;
      });
    }) : null;

    if(widget.clevelandArtwork.culture != null){
      translatedArtwork.culture = [];
      for(final culture in widget.clevelandArtwork.culture!){
        if(culture != null){
          culture.translate().then((value){
            setState(() {
              translatedArtwork.culture!.add(value);
            });
          });
        }else translatedArtwork.culture = null;
      }
    }else translatedArtwork.culture = null;

    widget.clevelandArtwork.measurements != null ? widget.clevelandArtwork.measurements!.translate().then((value){
      setState(() {
        translatedArtwork.measurements = value;
      });
    }) : null;

    widget.clevelandArtwork.technique != null ? widget.clevelandArtwork.technique!.translate().then((value){
      setState(() {
        translatedArtwork.technique = value;
      });
    }) : null;

    widget.clevelandArtwork.series != null ? widget.clevelandArtwork.series!.translate().then((value){
      setState(() {
        translatedArtwork.series = value;
      });
    }) : null;

    widget.clevelandArtwork.description != null ? widget.clevelandArtwork.description!.translate().then((value){
      setState(() {
        translatedArtwork.description = value;
      });
    }) : null;

    translated = true;
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
                Stack(
                  children: [
                    imageUrl != null ? Image.network(imageUrl!, width: double.infinity, fit: BoxFit.fitWidth) : Container(),
                    Positioned(
                      child: IconButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenView(imageUrl: imageUrl!,)));
                        },
                        icon: Icon(Icons.fullscreen, color: Colors.white,),
                        iconSize: 30,
                      ),
                      right: 0,
                      bottom: 0,
                    ),
                    Positioned(
                      child: IconButton(
                        onPressed: () async{
                          downloadImage(context, imageUrl!);
                        },
                        icon: Icon(Icons.download, color: Colors.white,),
                        iconSize: 30,
                      ),
                      right: 50,
                      bottom: 0,
                    ),
                  ],
                ),
                !showTranslated ? Column(
                  children: [
                    SizedBox(height: 20,),
                    widget.clevelandArtwork.title != null ? Center(
                        child: Text(
                          widget.clevelandArtwork.title!,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        )
                    ) : Container(),
                    SizedBox(height: 20,),
                    Container(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,

                        children: [
                          widget.clevelandArtwork.creationDate != null ? Text(
                              '제작일: ${widget.clevelandArtwork.creationDate}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
                          creatorsDescription != null ? Text(
                              '창작자: ${creatorsDescription!.join(', ')}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
                          widget.clevelandArtwork.department != null ? Text(
                              '부문: ${widget.clevelandArtwork.department}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
                          widget.clevelandArtwork.type != null ? Text(
                              '유형: ${widget.clevelandArtwork.type}', style: TextStyle(fontSize: 20,)
                          ) : Container(),
                          widget.clevelandArtwork.culture != null ? Text(
                              '문화: ${widget.clevelandArtwork.culture!.join(', ')}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
                          widget.clevelandArtwork.measurements != null ? Text(
                              '크기: ${widget.clevelandArtwork.measurements}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
                          widget.clevelandArtwork.technique != null ? Text(
                              '재료/기법: ${widget.clevelandArtwork.technique}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
                          widget.clevelandArtwork.series != null ? Text(
                              '시리즈: ${widget.clevelandArtwork.series}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
                          widget.clevelandArtwork.description != null ? Text(
                              '설명: ${widget.clevelandArtwork.description}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
                        ],
                      ),
                    ),
                  ],
                ) : Column(
                  children: [
                    SizedBox(height: 20,),
                    translatedArtwork.title != null ? Center(
                        child: Text(
                          translatedArtwork.title!,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        )
                    ) : Container(),
                    SizedBox(height: 20,),
                    Container(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          translatedArtwork.creationDate != null ? Text(
                              '제작일: ${translatedArtwork.creationDate}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
                          translatedCreatorsDescription != null ? Text(
                              '창작자: ${translatedCreatorsDescription!.join(', ')}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
                          translatedArtwork.department != null ?
                          Text('부문: ${translatedArtwork.department}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
                          translatedArtwork.type != null ? Text(
                              '유형: ${translatedArtwork.type}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
                          translatedArtwork.culture != null ?
                          Text('문화: ${translatedArtwork.culture!.join(', ')}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
                          translatedArtwork.measurements != null ? Text(
                              '크기: ${translatedArtwork.measurements}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
                          translatedArtwork.technique != null ? Text(
                              '재료/기법: ${translatedArtwork.technique}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
                          translatedArtwork.series != null ? Text(
                              '시리즈: ${translatedArtwork.series}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
                          translatedArtwork.description != null ? Text(
                              '설명: ${translatedArtwork.description}',
                              style: TextStyle(fontSize: 20,)
                          ) : Container(),
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