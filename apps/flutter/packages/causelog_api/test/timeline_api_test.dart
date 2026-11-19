import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for TimelineApi
void main() {
  final instance = Openapi().getTimelineApi();

  group(TimelineApi, () {
    // Recent project activity
    //
    //Future<ActivityResponse> getActivity(String projectId) async
    test('test getActivity', () async {
      // TODO
    });

    // Project timeline events
    //
    //Future<TimelineResponse> getTimeline(String projectId) async
    test('test getTimeline', () async {
      // TODO
    });

  });
}
