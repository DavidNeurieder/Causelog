import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for LinksApi
void main() {
  final instance = Openapi().getLinksApi();

  group(LinksApi, () {
    // Create a typed link
    //
    //Future<Link> createLink(String projectId, LinkCreateRequest linkCreateRequest, { String idempotencyKey }) async
    test('test createLink', () async {
      // TODO
    });

    // Delete a link
    //
    //Future deleteLink(String projectId, String linkId, { String idempotencyKey, CsrfBody csrfBody }) async
    test('test deleteLink', () async {
      // TODO
    });

  });
}
