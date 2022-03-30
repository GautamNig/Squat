class NYTimesLatestWorldNews {
  String? status;
  int? numResults;
  List<Results>? results;

  NYTimesLatestWorldNews(
      {status,
        numResults,
        results});

  NYTimesLatestWorldNews.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    numResults = json['num_results'];
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['num_results'] = numResults;
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? abstract;
  String? publishedDate;
  List<Multimedia>? multimedia;

  Results(
      {
        abstract,
        publishedDate,
        multimedia,
        });

  Results.fromJson(Map<String, dynamic> json) {
    abstract = json['abstract'];
    publishedDate = json['published_date'];
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
    data['published_date'] = publishedDate;
    if (multimedia != null) {
      data['multimedia'] = multimedia!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Multimedia {
  String? url;
  String? caption;

  Multimedia(
      {url,
        caption,
        });

  Multimedia.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    caption = json['caption'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['caption'] = caption;
    return data;
  }
}
