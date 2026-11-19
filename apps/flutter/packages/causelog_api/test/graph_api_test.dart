import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for GraphApi
void main() {
  final instance = Openapi().getGraphApi();

  group(GraphApi, () {
    // Project knowledge graph (nodes and typed edges)
    //
    //Future<GraphResponse> getGraph(String projectId, { String focus }) async
    test('test getGraph', () async {
      // TODO
    });

  });
}
