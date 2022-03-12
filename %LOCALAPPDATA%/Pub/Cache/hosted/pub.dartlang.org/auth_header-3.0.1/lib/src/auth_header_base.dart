// Copyright (c) 2016, Ravi Teja Gudapati. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library auth_header;

/// Represents an item in Authorisation header
class AuthHeaderItem {
  /// Authorisation scheme
  final String authScheme;

  /// Authorisation credentials
  final String credentials;

  AuthHeaderItem(this.authScheme, this.credentials);

  String toString() => '${authScheme} ${credentials}';

  /// Value returned by this function shall be added to request headers
  Map<String, String> toAuthorizationHeader() => {"authorization": toString()};

  /// Finds Authorisation header item in the given [header] by given [scheme]
  static AuthHeaderItem? fromHeaderBySchema(String? header, String scheme) =>
      AuthHeaders.headerStrToItems(header)[scheme];
}

class AuthHeaders {
  final Map<String, AuthHeaderItem> items;

  AuthHeaders.from(this.items);

  AuthHeaders() : items = {};

  factory AuthHeaders.fromHeaderStr(String? header) {
    return AuthHeaders.from(headerStrToItems(header));
  }

  void addItem(AuthHeaderItem item, {bool omitIfPresent: true}) {
    if (omitIfPresent && items.containsKey(item.authScheme)) {
      return;
    }

    items[item.authScheme] = item;
  }

  AuthHeaderItem? removeItemByScheme(String scheme) {
    return items.remove(scheme);
  }

  bool containsScheme(String scheme) => items.containsKey(scheme);

  bool get isEmpty => items.isEmpty;

  String toString() => items.values.map((h) => h.toString()).join(',');

  /// Value returned by this function shall be added to request headers
  Map<String, String> toAuthorizationHeader() => {"authorization": toString()};

  /// Creates and returns a Map of scheme to [AuthHeaderItem] from given [header]
  static Map<String, AuthHeaderItem> headerStrToItems(String? header) {
    if (header == null || header.isEmpty) {
      return {};
    }
    List<String> authHeaders = _splitAuthHeader(header);

    final map = <String, AuthHeaderItem>{};

    authHeaders.forEach((String headerStr) {
      final List<String> parts = headerStr.split(' ');

      if (parts.length != 2) {
        return;
      }

      map[parts[0]] = new AuthHeaderItem(parts[0], parts[1]);
    });

    return map;
  }

  /// Adds new authorisation item [newItem] to the authorisation header [header]
  static String addItemToHeaderStr(String? header, AuthHeaderItem newItem,
      {bool omitIfPresent: true}) {
    if (header == null) {
      header = '';
    }
    var auth = AuthHeaders.fromHeaderStr(header);

    if (omitIfPresent && auth.containsScheme(newItem.authScheme)) {
      return header;
    } else {
      auth.addItem(newItem, omitIfPresent: omitIfPresent);
      return auth.toString();
    }
  }

  /// Removed the requested scheme from the header
  static String removeSchemeFromHeaderStr(String? header, String scheme) {
    if (header == null || header.isEmpty) {
      return '';
    }
    AuthHeaders auth = AuthHeaders.fromHeaderStr(header);

    if (auth.isEmpty || !auth.containsScheme(scheme)) {
      return header;
    }

    auth.removeItemByScheme(scheme);

    return auth.toString();
  }
}

/// Splits Authorisation header into items
List<String> _splitAuthHeader(String header) {
  return header == null ? [] : header.split(',');
}
