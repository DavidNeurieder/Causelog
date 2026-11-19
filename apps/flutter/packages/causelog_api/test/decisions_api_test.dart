import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for DecisionsApi
void main() {
  final instance = Openapi().getDecisionsApi();

  group(DecisionsApi, () {
    // Compare two decision revisions (Markdown diff)
    //
    //Future<RevisionComparison> compareDecisionRevisions(String decisionId, String from, String to) async
    test('test compareDecisionRevisions', () async {
      // TODO
    });

    // Create a decision (appends initial revision)
    //
    //Future<Decision> createDecision(String projectId, DecisionCreateRequest decisionCreateRequest, { String idempotencyKey }) async
    test('test createDecision', () async {
      // TODO
    });

    // Delete a decision
    //
    //Future deleteDecision(String decisionId, { String idempotencyKey, CsrfBody csrfBody }) async
    test('test deleteDecision', () async {
      // TODO
    });

    // Get a decision
    //
    //Future<Decision> getDecision(String decisionId) async
    test('test getDecision', () async {
      // TODO
    });

    // List decision revisions (newest first)
    //
    //Future<RevisionPage> listDecisionRevisions(String decisionId) async
    test('test listDecisionRevisions', () async {
      // TODO
    });

    // List decisions
    //
    //Future<DecisionPage> listDecisions(String projectId, { int page, int perPage, DecisionStatus status }) async
    test('test listDecisions', () async {
      // TODO
    });

    // Resolve a decision (appends revision)
    //
    //Future<Decision> resolveDecision(String decisionId, DecisionResolveRequest decisionResolveRequest, { String idempotencyKey }) async
    test('test resolveDecision', () async {
      // TODO
    });

    // Update a decision (appends revision)
    //
    //Future<Decision> updateDecision(String decisionId, DecisionUpdateRequest decisionUpdateRequest, { String idempotencyKey }) async
    test('test updateDecision', () async {
      // TODO
    });

  });
}
