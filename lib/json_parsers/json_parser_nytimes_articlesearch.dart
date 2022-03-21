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

  Docs(
      {this.abstract,
        this.snippet,
        this.leadParagraph,
        this.source,
        this.pubDate});

  Docs.fromJson(Map<String, dynamic> json) {
    abstract = json['abstract'];
    snippet = json['snippet'];
    leadParagraph = json['lead_paragraph'];
    source = json['source'];
    pubDate = json['pub_date'];
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
