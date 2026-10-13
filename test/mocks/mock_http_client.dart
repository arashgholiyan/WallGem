import 'package:http/http.dart' as http;

/// A lightweight mock HTTP client for hermetic network testing.
class MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request) handler;

  MockHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

/// Helper function to create a mock client returning a fixed status code and body.
http.Client createMockHttpClient({
  required String responseBody,
  required int statusCode,
}) {
  return MockHttpClient((request) async {
    return http.Response(
      responseBody,
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
}
