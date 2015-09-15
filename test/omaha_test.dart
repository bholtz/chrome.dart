library omaha_test;

import 'dart:async';

import '../tool/src/omaha.dart';
import '../tool/src/simple_http_client.dart';
import 'package:mock/mock.dart';
import 'package:test/test.dart';

void main() => defineTests();

void defineTests() {
  group('OmahaVersionExtractor', () {
    OmahaVersionExtractor extractor;
    MockSimpleHttpClient client;
    var html;

    setUp(() {
      client = new MockSimpleHttpClient();
      client.when(callsTo('getHtmlAtUri')).alwaysCall((_) => new Future.value(html));
      extractor = new OmahaVersionExtractor(client);
    });

    test('correctly parses good, simple input', () async {
      var version = 'alpha';
      html = 'mac,stable,$version';

      expect(await extractor.stableVersion, version);
    });
  });
}

class MockSimpleHttpClient extends Mock implements SimpleHttpClient {
  noSuchMethod(Invocation msg) => super.noSuchMethod(msg);
}
