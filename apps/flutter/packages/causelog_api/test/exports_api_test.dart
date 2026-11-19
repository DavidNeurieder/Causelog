import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for ExportsApi
void main() {
  final instance = Openapi().getExportsApi();

  group(ExportsApi, () {
    // Export format manifest and download URLs
    //
    //Future<ExportManifest> listExports(String projectId) async
    test('test listExports', () async {
      // TODO
    });

  });
}
