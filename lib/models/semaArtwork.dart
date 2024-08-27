class SemaArtwork {
  String? prdctClNm;
  String? manageNoYear;
  String? prdctNmKorean;
  String? prdctNmEng;
  String? prdctStndrd;
  String? mnfctYear;
  String? matrlTechnic;
  String? prdctDetail;
  String? writrNm;
  String? mainImage;
  String? thumbImage;

  SemaArtwork(
      {this.prdctClNm,
        this.manageNoYear,
        this.prdctNmKorean,
        this.prdctNmEng,
        this.prdctStndrd,
        this.mnfctYear,
        this.matrlTechnic,
        this.prdctDetail,
        this.writrNm,
        this.mainImage,
        this.thumbImage});

  SemaArtwork.fromJson(Map<String, dynamic> json) {
    prdctClNm = json['prdct_cl_nm'];
    manageNoYear = json['manage_no_year'];
    prdctNmKorean = json['prdct_nm_korean'];
    prdctNmEng = json['prdct_nm_eng'];
    prdctStndrd = json['prdct_stndrd'];
    mnfctYear = json['mnfct_year'];
    matrlTechnic = json['matrl_technic'];
    prdctDetail = json['prdct_detail'];
    writrNm = json['writr_nm'];
    mainImage = json['main_image'];
    thumbImage = json['thumb_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['prdct_cl_nm'] = this.prdctClNm;
    data['manage_no_year'] = this.manageNoYear;
    data['prdct_nm_korean'] = this.prdctNmKorean;
    data['prdct_nm_eng'] = this.prdctNmEng;
    data['prdct_stndrd'] = this.prdctStndrd;
    data['mnfct_year'] = this.mnfctYear;
    data['matrl_technic'] = this.matrlTechnic;
    data['prdct_detail'] = this.prdctDetail;
    data['writr_nm'] = this.writrNm;
    data['main_image'] = this.mainImage;
    data['thumb_image'] = this.thumbImage;
    return data;
  }
}