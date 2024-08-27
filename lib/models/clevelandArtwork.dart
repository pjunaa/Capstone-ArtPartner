class ClevelandArtwork {
  String? title;
  Images? images;
  String? series;
  String? creationDate;
  List<Creators>? creators;
  List<String>? culture;
  String? technique;
  String? department;
  String? type;
  String? measurements;
  String? description;

  ClevelandArtwork.clone(ClevelandArtwork clevelandArtwork) : this();

  ClevelandArtwork(
      {this.title, this.images, this.series, this.creationDate, this.creators, this.culture, this.technique, this.department, this.type, this.measurements, this.description});

  ClevelandArtwork.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    images = json['images'] != null ? new Images.fromJson(json['images']) : null;
    series = json['series'];
    creationDate = json['creation_date'];
    if (json['creators'] != null) {
      creators = <Creators>[];
      json['creators'].forEach((v) {
        creators!.add(new Creators.fromJson(v));
      });
    }
    culture = json['culture'].cast<String>();
    technique = json['technique'];
    department = json['department'];
    type = json['type'];
    measurements = json['measurements'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    if (this.images != null) {
      data['images'] = this.images!.toJson();
    }
    data['series'] = this.series;
    data['creation_date'] = this.creationDate;
    if (this.creators != null) {
      data['creators'] = this.creators!.map((v) => v.toJson()).toList();
    }
    data['culture'] = this.culture;
    data['technique'] = this.technique;
    data['department'] = this.department;
    data['type'] = this.type;
    data['measurements'] = this.measurements;
    data['description'] = this.description;
    return data;
  }
}

class Images {
  String? annotation;
  Web? web;
  Web? print;
  Web? full;

  Images({this.annotation, this.web, this.print, this.full});

  Images.fromJson(Map<String, dynamic> json) {
    annotation = json['annotation'];
    web = json['web'] != null ? new Web.fromJson(json['web']) : null;
    print = json['print'] != null ? new Web.fromJson(json['print']) : null;
    full = json['full'] != null ? new Web.fromJson(json['full']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['annotation'] = this.annotation;
    if (this.web != null) {
      data['web'] = this.web!.toJson();
    }
    if (this.print != null) {
      data['print'] = this.print!.toJson();
    }
    if (this.full != null) {
      data['full'] = this.full!.toJson();
    }
    return data;
  }
}

class Web {
  String? url;
  String? width;
  String? height;
  String? filesize;
  String? filename;

  Web({this.url, this.width, this.height, this.filesize, this.filename});

  Web.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    width = json['width'];
    height = json['height'];
    filesize = json['filesize'];
    filename = json['filename'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['width'] = this.width;
    data['height'] = this.height;
    data['filesize'] = this.filesize;
    data['filename'] = this.filename;
    return data;
  }
}

class Creators {
  String? description;
  String? extent;
  String? qualifier;
  String? role;
  String? biography;
  String? nameInOriginalLanguage;
  String? birthYear;
  String? deathYear;

  Creators(
      {this.description,
        this.extent,
        this.qualifier,
        this.role,
        this.biography,
        this.nameInOriginalLanguage,
        this.birthYear,
        this.deathYear});

  Creators.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    extent = json['extent'];
    qualifier = json['qualifier'];
    role = json['role'];
    biography = json['biography'];
    nameInOriginalLanguage = json['name_in_original_language'];
    birthYear = json['birth_year'];
    deathYear = json['death_year'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['extent'] = this.extent;
    data['qualifier'] = this.qualifier;
    data['role'] = this.role;
    data['biography'] = this.biography;
    data['name_in_original_language'] = this.nameInOriginalLanguage;
    data['birth_year'] = this.birthYear;
    data['death_year'] = this.deathYear;
    return data;
  }
}