library simple_http_client;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Encapsulates an [HttpClient] and automatically decodes UTF8 unescapes HTML
/// at the requested [Uri].
class SimpleHttpClient {
  static const _encodedCharacters = const ['\'', '&', '<', '>', '\"'];
  static final encodings =
      new Map.fromIterable(_encodedCharacters, key: HTML_ESCAPE.convert);
  final HttpClient _client;

  SimpleHttpClient(this._client);

  Future<String> getHtmlAtUri(Uri uri) async {
    HttpClientRequest request = await _client.getUrl(uri);
    request.close();
    HttpClientResponse response = await request.done;
    return _unescapeHtml(await response.transform(UTF8.decoder).join(''));
  }

  String _unescapeHtml(String escapedHtml) {
    encodings.forEach((encodedString, decodedString) {
      escapedHtml = escapedHtml.replaceAll(encodedString, decodedString);
    });
    return escapedHtml;
  }
}
