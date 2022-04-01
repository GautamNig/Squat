class Configuration {
  AppSettings? appSettings;

  Configuration({this.appSettings});

  Configuration.fromJson(Map<String, dynamic> json) {
    appSettings = json['AppSettings'] != null
        ? AppSettings.fromJson(json['AppSettings'])
        : null;
  }
}

class AppSettings {
  List<String>? giphyKey;
  List<String>? developerMessages;
  List<String>? nyTimesApiKey;
  List<String>? squatWaitTime;
  List<String>? graphCountryCount;
  List<String>? snackBarTimeDuration;
  List<String>? nyTimesApiSearchTerms;
  List<String>? generalMessages;
  List<String>? newsApi;

  AppSettings({this.giphyKey,
    this.developerMessages,
    this.nyTimesApiKey,
    this.squatWaitTime,
    this.graphCountryCount,
    this.snackBarTimeDuration,
    this.nyTimesApiSearchTerms,
    this.generalMessages,
    this.newsApi
  });

  AppSettings.fromJson(Map<String, dynamic> json) {
    giphyKey = json['giphyKey'].cast<String>();
    developerMessages = json['developerMessages'].cast<String>();
    nyTimesApiKey = json['nyTimesApiKey'].cast<String>();
    squatWaitTime = json['squatWaitTime'].cast<String>();
    graphCountryCount = json['graphCountryCount'].cast<String>();
    snackBarTimeDuration = json['snackBarTimeDuration'].cast<String>();
    nyTimesApiSearchTerms = json['nyTimesApiSearchTerms'].cast<String>();
    generalMessages = json['generalMessages'].cast<String>();
    generalMessages = json['newsApi'].cast<String>();
  }
}
