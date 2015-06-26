library simple_http_client_test;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../tool/simple_http_client.dart';
import 'package:mock/mock.dart';
import 'package:unittest/unittest.dart';

void main() => defineTests();

void defineTests() {
  group('SimpleHttpClient', () {
    SimpleHttpClient simpleClient;
    MockHttpClient mockClient;
    MockHttpClientRequest mockRequest;
    MockHttpClientResponse mockResponse;
    List<String> html;

    setUp(() {
      mockClient = new MockHttpClient();
      mockRequest = new MockHttpClientRequest();
      mockResponse = new MockHttpClientResponse();
      mockClient.when(callsTo('getUrl')).alwaysReturn(mockRequest);
      mockRequest
          .when(callsTo('get done'))
          .alwaysReturn(new Future(() => mockResponse));
      mockResponse.when(callsTo('transform')).alwaysCall((_) => html);

      simpleClient = new SimpleHttpClient(mockClient);
    });

    test('returns string', () async {
      var testString = 'this is some great testHtml';
      html = [testString];

      expect(await simpleClient.getHtmlAtUri(Uri.parse('example.com')),
          testString);
    });

    test('unescapes html correctly', () async {
      var testString = 'this & that is <\"\'>';
      html = [HTML_ESCAPE.convert(testString)];

      expect(await simpleClient.getHtmlAtUri(Uri.parse('example.com')),
          testString);
    });
  });
}

class MockHttpClient extends Mock implements HttpClient {
  noSuchMethod(Invocation msg) => super.noSuchMethod(msg);
}

class MockHttpClientRequest extends Mock implements HttpClientRequest {
  noSuchMethod(Invocation msg) => super.noSuchMethod(msg);
}

class MockHttpClientResponse extends Mock implements HttpClientResponse {
  noSuchMethod(Invocation msg) => super.noSuchMethod(msg);
}
