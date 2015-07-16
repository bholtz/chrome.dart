library download_idls;

import 'dart:async';
import 'dart:io';

import 'googlesource.dart';
import 'omaha.dart';
import 'simple_http_client.dart';

main() {
  new IdlDownloader(new SimpleHttpClient(new HttpClient())).downloadIdls();
}

class IdlDownloader {
  static const chromiumBaseUrl = 'https://chromium.googlesource.com';
  static const chromiumVersionPrefix = '/chromium/src/+/';
  static const idlDirs = const ['chrome', 'extensions'];
  final SimpleHttpClient _client;
  OmahaVersionExtractor _omahaVersionExtractor;
  GoogleSourceCrawler _googleSourceCrawler;
  String _version;

  IdlDownloader(this._client);

  Future downloadIdls() async {
    _omahaVersionExtractor = new OmahaVersionExtractor(_client);
    _version = await _omahaVersionExtractor.stableVersion;
    _googleSourceCrawler = new GoogleSourceCrawler(_client, chromiumBaseUrl);
    for (var dir in idlDirs) {
      var relativePath = '$chromiumVersionPrefix$_version/$dir';
      _googleSourceCrawler.findAllMatchingFiles(relativePath).listen(_downloadFile);
    }
  }

  Future _downloadFile(GoogleSourceFile file) async {
    var filePath = file.url.replaceFirst('/', '');
    print(filePath);
    var fp = new File(filePath);
    await fp.create(recursive: true);
    await fp.writeAsString(file.fileContents);
  }
}