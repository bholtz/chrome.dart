library omaha;

import 'dart:async';

import 'simple_http_client.dart';

class OmahaVersionExtractor {
  static const _omahaDataUrl = 'https://omahaproxy.appspot.com/all?csv=1';
  final SimpleHttpClient _client;

  OmahaVersionExtractor(this._client);

  Future<String> get stableVersion async {
    var omahaData = await _client.getHtmlAtUri(Uri.parse(_omahaDataUrl));
    var stableCommits = omahaData.split('\n')
      ..removeWhere((line) => !line.contains('stable') || line.contains('N/A'));
    var stableCommitVersions = new Map.fromIterable(stableCommits,
        key: (line) => line.split(',')[0], value: (line) => line.split(',')[2]);
    return stableCommitVersions['mac'];
  }
}
