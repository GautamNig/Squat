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
  List<String>? giphyTestKey;
  List<String>? giphyProdKey;
  List<String>? nyTimesApiKey;
  List<String>? squatWaitTime;
  List<String>? graphCountryCount;
  List<String>? snackBarTimeDuration;
  List<String>? nyTimesApiSearchTerms;
  List<String>? generalMessages;

  AppSettings({this.giphyTestKey,
    this.giphyProdKey,
    this.nyTimesApiKey,
    this.squatWaitTime,
    this.graphCountryCount,
    this.snackBarTimeDuration,
    this.nyTimesApiSearchTerms,
    this.generalMessages
  });

  AppSettings.fromJson(Map<String, dynamic> json) {
    giphyTestKey = json['giphyTestKey'].cast<String>();
    giphyProdKey = json['giphyProdKey'].cast<String>();
    nyTimesApiKey = json['nyTimesApiKey'].cast<String>();
    squatWaitTime = json['squatWaitTime'].cast<String>();
    graphCountryCount = json['graphCountryCount'].cast<String>();
    snackBarTimeDuration = json['snackBarTimeDuration'].cast<String>();
    nyTimesApiSearchTerms = json['nyTimesApiSearchTerms'].cast<String>();
    generalMessages = json['generalMessages'].cast<String>();
  }
}
