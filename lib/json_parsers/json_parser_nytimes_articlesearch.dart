class NYTimesArticleSearch {
  String? status;
  Response? response;

  NYTimesArticleSearch({this.status, this.response});

  NYTimesArticleSearch.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    response = json['response'] != null
        ? Response.fromJson(json['response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (response != null) {
      data['response'] = response!.toJson();
    }
    return data;
  }
}

class Response {
  List<Docs>? docs;

  Response({docs});

  Response.fromJson(Map<String, dynamic> json) {
    if (json['docs'] != null) {
      docs = <Docs>[];
      json['docs'].forEach((v) {
        docs!.add(Docs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (docs != null) {
      data['docs'] = docs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Docs {
  String? abstract;
  String? snippet;
  String? leadParagraph;
  String? source;
  String? pubDate;
  List<Multimedia>? multimedia;
  Docs(
      {this.abstract,
        this.snippet,
        this.leadParagraph,
        this.source,
        this.pubDate, this.multimedia});

  Docs.fromJson(Map<String, dynamic> json) {
    abstract = json['abstract'];
    snippet = json['snippet'];
    leadParagraph = json['lead_paragraph'];
    source = json['source'];
    pubDate = json['pub_date'];
    if (json['multimedia'] != null) {
      multimedia = <Multimedia>[];
      json['multimedia'].forEach((v) {
        multimedia!.add(Multimedia.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['abstract'] = abstract;
    data['snippet'] = snippet;
    data['lead_paragraph'] = leadParagraph;
    data['source'] = source;
    data['pub_date'] = pubDate;
    return data;
  }
}

class Multimedia {
  String? url;

  Multimedia({this.url});

  Multimedia.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    return data;
  }
}
