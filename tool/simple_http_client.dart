library simple_http_client;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Encapsulates an [HttpClient] for accessing HTML at a given [URI].
class SimpleHttpClient {
  final HttpClient _client;

  SimpleHttpClient(this._client);

  Future<String> getHtmlAtUri(Uri uri) async {
    HttpClientRequest request = await _client.getUrl(uri);
    request.close();
    HttpClientResponse response = await request.done;
    return await response.transform(UTF8.decoder).join('');
  }
}

//
class ThrottledHttpClient extends SimpleHttpClient {
  static final quotaRefreshDuration = new Duration(minutes: 5, seconds: 30);
  static final requestQuota = 600;
  static final _quotaRefreshed = 'QUOTA_REFRESHED';
  Map<Uri, int> _requestCounts;
  StreamController _quotaRefreshStreamController;
  Stream _quotaRefreshStream;

  ThrottledHttpClient(client) : super(client) {
    _requestCounts = {};
    _quotaRefreshStreamController = new StreamController.broadcast();
    _quotaRefreshStream = _quotaRefreshStreamController.stream;
    new Timer.periodic(quotaRefreshDuration, (_) => _resetRequestCounts());
  }

  void _resetRequestCounts() {
    _requestCounts.forEach((key, _) => _requestCounts[key] = 0);
    _quotaRefreshStreamController.add(_quotaRefreshed);
  }

  @override
  Future<String> getHtmlAtUri(Uri uri) async {
    var host = uri.host;
    if (_requestCounts.keys.contains(host)) {
      _requestCounts[host]++;
    } else {
      _requestCounts[host] = 1;
    }

    await _ensureWithinQuota(host);

    return super.getHtmlAtUri(uri);
  }

  Future _ensureWithinQuota(host) async {
    if (_requestCounts[host] < requestQuota) return;

    print('Quota exceeded. Waiting to prevent throttling.');
    // Wait for the next quota refresh.
    await _quotaRefreshStream.take(1);
  }
}
