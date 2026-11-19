import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for ExperimentsApi
void main() {
  final instance = Openapi().getExperimentsApi();

  group(ExperimentsApi, () {
    // Create an experiment
    //
    //Future<Experiment> createExperiment(String projectId, ExperimentCreateRequest experimentCreateRequest, { String idempotencyKey }) async
    test('test createExperiment', () async {
      // TODO
    });

    // Add an observation/measurement/milestone
    //
    //Future<ExperimentEvent> createExperimentEvent(String experimentId, ExperimentEventCreateRequest experimentEventCreateRequest, { String idempotencyKey }) async
    test('test createExperimentEvent', () async {
      // TODO
    });

    // Delete an experiment
    //
    //Future deleteExperiment(String experimentId, { String idempotencyKey, CsrfBody csrfBody }) async
    test('test deleteExperiment', () async {
      // TODO
    });

    // Delete an experiment event
    //
    //Future deleteExperimentEvent(String experimentId, String eventId, { String idempotencyKey, CsrfBody csrfBody }) async
    test('test deleteExperimentEvent', () async {
      // TODO
    });

    // Extract a lesson into a note
    //
    //Future<Note> extractExperimentLesson(String experimentId, ExtractLessonRequest extractLessonRequest, { String idempotencyKey }) async
    test('test extractExperimentLesson', () async {
      // TODO
    });

    // Get an experiment with events
    //
    //Future<ExperimentDetail> getExperiment(String experimentId) async
    test('test getExperiment', () async {
      // TODO
    });

    // List experiments
    //
    //Future<ExperimentPage> listExperiments(String projectId, { int page, int perPage }) async
    test('test listExperiments', () async {
      // TODO
    });

    // Update an experiment
    //
    //Future<Experiment> updateExperiment(String experimentId, ExperimentUpdateRequest experimentUpdateRequest, { String idempotencyKey }) async
    test('test updateExperiment', () async {
      // TODO
    });

  });
}
