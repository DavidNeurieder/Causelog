import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for GoalsApi
void main() {
  final instance = Openapi().getGoalsApi();

  group(GoalsApi, () {
    // Create a goal
    //
    //Future<Goal> createGoal(String projectId, GoalCreateRequest goalCreateRequest, { String idempotencyKey }) async
    test('test createGoal', () async {
      // TODO
    });

    // Delete a goal
    //
    //Future deleteGoal(String goalId, { String idempotencyKey, CsrfBody csrfBody }) async
    test('test deleteGoal', () async {
      // TODO
    });

    // Get a goal
    //
    //Future<Goal> getGoal(String goalId) async
    test('test getGoal', () async {
      // TODO
    });

    // List goals
    //
    //Future<GoalPage> listGoals(String projectId, { int page, int perPage, GoalStatus status }) async
    test('test listGoals', () async {
      // TODO
    });

    // Update a goal
    //
    //Future<Goal> updateGoal(String goalId, GoalUpdateRequest goalUpdateRequest, { String idempotencyKey }) async
    test('test updateGoal', () async {
      // TODO
    });

  });
}
