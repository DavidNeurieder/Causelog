import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for SearchApi
void main() {
  final instance = Openapi().getSearchApi();

  group(SearchApi, () {
    // Full-text search (FTS5-backed)
    //
    //Future<SearchPage> search({ String q, String projectId, int page, int perPage }) async
    test('test search', () async {
      // TODO
    });

  });
}
