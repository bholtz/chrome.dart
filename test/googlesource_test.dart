library googlesource_test;

import 'dart:async';
import 'dart:convert';

import '../tool/googlesource.dart';
import '../tool/simple_http_client.dart';
import 'package:mock/mock.dart';
import 'package:unittest/unittest.dart';

void main() => defineTests();

void defineTests() {
  group('GoogleSourceFile', () {
    GoogleSourceFile file;

    void testHtmlConversion(List<String> lines) {
      file = new GoogleSourceFile(asHtml(lines), 'example.com');

      expect(file.fileContents, lines.join('\n'));
    }

    test('correctly parses simple raw html', () {
      testHtmlConversion(['just one line']);
    });

    test('correctly parses multiline raw html', () {
      testHtmlConversion(['multiple', 'small', 'lines']);
    });

    test('correctly parses multiline raw html with whitespace', () {
      testHtmlConversion(['if (true)', '  goto label;', '', '', 'label']);
    });

    test('unescapes files', () {
      var testEscapeString = 'this & that is <\"\'>';
      var escapedHtmlFile = '<ol><li><a name="1"></a><span>'
          '${HTML_ESCAPE.convert(testEscapeString)}</span></li></ol>';
      file = new GoogleSourceFile(escapedHtmlFile, 'www.example.com');

      expect(file.fileContents, testEscapeString);
    });
  });

  group('GoogleSourceCrawler', () {
    var baseUri = 'http://www.example.com/';
    MockSimpleHttpClient client;
    GoogleSourceCrawler crawler;

    setUp(() {
      client = new MockSimpleHttpClient();
      crawler = new GoogleSourceCrawler(client, baseUri);

      client.when(callsTo('getHtmlAtUri'))
        ..thenReturn(new Future.value())
        ..alwaysReturn(new Future.value(''));
    });

    test('returns correct files in single directory', () async {
      prepopulateHttpResponses(client, test1);

      var files = await crawler.findAllMatchingFiles('test').toList();

      expect(files.length, 3);
      expect(files[0].url, '/test/a.idl');
      expect(files[1].url, '/test/b.idl');
      expect(files[2].url, '/test/c.idl');
    });

    test('correctly follows the file tree', () async {
      prepopulateHttpResponses(client, test2);

      var files = await crawler.findAllMatchingFiles('test').toList();

      expect(files.length, 1);
      expect(files.single.url, '/test/foo/bar/baz/qux.idl');
    });

    test('rejects files with non-matching extensions', () async {
      prepopulateHttpResponses(client, test3);

      var files = await crawler.findAllMatchingFiles('test').toList();

      expect(files.length, 2);
      expect(files[0].url, '/test/a.idl');
      expect(files[1].url, '/test/c.json');
    });
  });
}

void prepopulateHttpResponses(
    MockSimpleHttpClient mockClient, List<String> responses) {
  mockClient.reset();
  for (var response in responses) {
    mockClient
        .when(callsTo('getHtmlAtUri'))
        .thenReturn(new Future.value(response));
  }
}

class MockSimpleHttpClient extends Mock implements SimpleHttpClient {
  noSuchMethod(Invocation msg) => super.noSuchMethod(msg);
}

var test1 = [
  '<ol>'
      '<li><a href="/test/a.idl">a.idl</a></li>'
      '<li><a href="/test/b.idl">b.idl</a></li>'
      '<li><a href="/test/c.idl">c.idl</a></li>'
      '</ol>',
  'a contents',
  'b contents',
  'c contents'
];

var test2 = [
  '<ol><li><a href="/test/foo/">foo</a></li></ol>',
  '<ol><li><a href="/test/foo/bar/">bar</a></li></ol>',
  '<ol><li><a href="/test/foo/bar/baz/">baz</a></li></ol>',
  '<ol><li><a href="/test/foo/bar/baz/qux.idl">qux.idl</a></li></ol>',
  'qux contents'
];

var test3 = [
  '<ol><li><a href="/test/a.idl">a.idl</a></li>'
      '<li><a href="/test/b.txt">b.txt</a></li>'
      '<li><a href="/test/c.json">c.json</a></li></ol>',
  'a contents',
  'b contents',
  'c contents'
];

String asHtml(List<String> lines) {
  var liHtml = lines.map((line) => '<li><a></a><span>$line</span></li>').join();
  return '<ol>$liHtml</ol>';
}

var multilineFileHtml = '''<ol>
  <li><a name="1"></a><span>first line</span></li>
  <li><a name="2"></a><span>  second line</span></li>
  <li><a name="3"></a><span>just one line</span></li>
  <li><a name="4"></a><span>just one line</span></li>
  <li><a name="5"></a><span>just one line</span></li>
  <li><a name="6"></a><span>just one line</span></li>
</ol>''';