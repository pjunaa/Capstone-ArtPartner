import 'package:flutter/material.dart';

class SemaSource extends StatelessWidget {
  const SemaSource({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: CloseButton(style: ButtonStyle(iconSize: MaterialStateProperty.all(30))),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("출처", textAlign: TextAlign.center,style: TextStyle(fontSize: 20),),
            SizedBox(height: 10),
            Text("본 저작물은 공공누리 제4유형에 따라 \n서울특별시(https://data.seoul.go.kr/dataList/OA-15321/S/1/datasetView.do), 작성자:한지숙의 \n공공저작물을 이용하였습니다.", textAlign: TextAlign.center,style: TextStyle(fontSize: 20),),
          ],
        ),
      ),
    );
  }
}
