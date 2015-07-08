library googlesource;

import 'dart:async';
import 'dart:convert';

import 'simple_http_client.dart';
import 'tag_matcher.dart';

abstract class GoogleSourceEntity {
  final String _rawHtml;
  final String _url;

  GoogleSourceEntity(this._rawHtml, this._url);
  String get url => _url;
  String get _lines => TagMatcher.olMatcher.allContents(_rawHtml).single;
}

class GoogleSourceFile extends GoogleSourceEntity {
  static const _encodedCharacters = const ['\'', '&', '<', '>', '\"'];
  static final encodings =
      new Map.fromIterable(_encodedCharacters, key: HTML_ESCAPE.convert);

  GoogleSourceFile(rawHtml, url) : super(rawHtml, url);

  String get fileContents => _unescapeHtml(TagMatcher.liMatcher
      .allContents(_lines)
      .map((line) {
    var lineStripped = line.replaceFirst(TagMatcher.aMatcher, '');
    return TagMatcher.spanMatcher.allContents(lineStripped).join('');
  }).join('\n'));

  String _unescapeHtml(String escapedHtml) {
    encodings.forEach((encodedString, decodedString) {
      escapedHtml = escapedHtml.replaceAll(encodedString, decodedString);
    });
    return escapedHtml;
  }
}

class GoogleSourceDirectory extends GoogleSourceEntity {
  GoogleSourceDirectory(rawHtml, url) : super(rawHtml, url);

  Iterable<String> get listUris => TagMatcher.aMatcher
      .allAttributes(_lines)
      .map((Map<String, String> attributes) => attributes['href']);
}

class GoogleSourceCrawler {
  static const matchingExtensions = const ['.idl', '.json'];

  final SimpleHttpClient _client;
  final String _baseUri;

  GoogleSourceCrawler(this._client, this._baseUri);

  Stream<GoogleSourceFile> findAllMatchingFiles(String relativeUri) async* {
    var directory = new GoogleSourceDirectory(
        await _client.getHtmlAtUri(_absoluteUri(relativeUri)), relativeUri);
    for (var childUrl in directory.listUris) {
      if (childUrl.endsWith('/')) {
        yield* findAllMatchingFiles(childUrl);
      } else if (matchingExtensions.any((ext) => childUrl.endsWith(ext))) {
        yield new GoogleSourceFile(
            await _client.getHtmlAtUri(_absoluteUri(childUrl)), childUrl);
      }
    }
  }

  Uri _absoluteUri(String relativeUri) => Uri.parse('$_baseUri$relativeUri');
}