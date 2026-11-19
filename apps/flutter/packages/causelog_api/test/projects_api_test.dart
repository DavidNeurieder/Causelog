import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for ProjectsApi
void main() {
  final instance = Openapi().getProjectsApi();

  group(ProjectsApi, () {
    // Add a project member (admin or project owner)
    //
    //Future addProjectMember(String projectId, ProjectMemberAddRequest projectMemberAddRequest, { String idempotencyKey }) async
    test('test addProjectMember', () async {
      // TODO
    });

    // Create a project
    //
    //Future<Project> createProject(ProjectCreateRequest projectCreateRequest, { String idempotencyKey }) async
    test('test createProject', () async {
      // TODO
    });

    // Delete a project
    //
    //Future deleteProject(String projectId, { String idempotencyKey, CsrfBody csrfBody }) async
    test('test deleteProject', () async {
      // TODO
    });

    // Get a project
    //
    //Future<Project> getProject(String projectId) async
    test('test getProject', () async {
      // TODO
    });

    // Project statistics
    //
    //Future<ProjectStats> getProjectStats(String projectId) async
    test('test getProjectStats', () async {
      // TODO
    });

    // List project members
    //
    //Future<ListProjectMembers200Response> listProjectMembers(String projectId) async
    test('test listProjectMembers', () async {
      // TODO
    });

    // List projects accessible to the current user
    //
    //Future<ProjectPage> listProjects({ int page, int perPage }) async
    test('test listProjects', () async {
      // TODO
    });

    // Remove a project member
    //
    //Future removeProjectMember(String projectId, String userId, { String idempotencyKey, CsrfBody csrfBody }) async
    test('test removeProjectMember', () async {
      // TODO
    });

    // Update a project
    //
    //Future<Project> updateProject(String projectId, ProjectUpdateRequest projectUpdateRequest, { String idempotencyKey }) async
    test('test updateProject', () async {
      // TODO
    });

  });
}
