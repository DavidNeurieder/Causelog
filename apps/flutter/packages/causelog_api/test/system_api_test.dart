import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for SystemApi
void main() {
  final instance = Openapi().getSystemApi();

  group(SystemApi, () {
    // Server capabilities and version
    //
    //Future<Capabilities> getCapabilities() async
    test('test getCapabilities', () async {
      // TODO
    });

    // Whether initial setup is required
    //
    //Future<SetupStatus> getSetupStatus() async
    test('test getSetupStatus', () async {
      // TODO
    });

    // Liveness probe (existing)
    //
    //Future<Health200Response> health() async
    test('test health', () async {
      // TODO
    });

  });
}
