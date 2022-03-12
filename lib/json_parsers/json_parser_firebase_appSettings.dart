class Configuration {
  AppSettings? appSettings;

  Configuration({this.appSettings});

  Configuration.fromJson(Map<String, dynamic> json) {
    appSettings = json['AppSettings'] != null
        ? AppSettings.fromJson(json['AppSettings'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (appSettings != null) {
      data['AppSettings'] = appSettings!.toJson();
    }
    return data;
  }
}

class AppSettings {
  List<String>? customToken;
  List<String>? androidKey;

  AppSettings({this.customToken, this.androidKey});

  AppSettings.fromJson(Map<String, dynamic> json) {
    customToken = json['CustomToken'].cast<String>();
    androidKey = json['AndroidKey'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CustomToken'] = customToken;
    data['AndroidKey'] = androidKey;
    return data;
  }
}
