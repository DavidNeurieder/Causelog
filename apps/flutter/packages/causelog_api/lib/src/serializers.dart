//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:openapi/src/date_serializer.dart';
import 'package:openapi/src/model/date.dart';

import 'package:openapi/src/model/activity_item.dart';
import 'package:openapi/src/model/activity_response.dart';
import 'package:openapi/src/model/capabilities.dart';
import 'package:openapi/src/model/capabilities_auth.dart';
import 'package:openapi/src/model/capture_request.dart';
import 'package:openapi/src/model/capture_response.dart';
import 'package:openapi/src/model/csrf_body.dart';
import 'package:openapi/src/model/decision.dart';
import 'package:openapi/src/model/decision_create_request.dart';
import 'package:openapi/src/model/decision_option.dart';
import 'package:openapi/src/model/decision_page.dart';
import 'package:openapi/src/model/decision_resolve_request.dart';
import 'package:openapi/src/model/decision_status.dart';
import 'package:openapi/src/model/decision_update_request.dart';
import 'package:openapi/src/model/error.dart';
import 'package:openapi/src/model/experiment.dart';
import 'package:openapi/src/model/experiment_create_request.dart';
import 'package:openapi/src/model/experiment_detail.dart';
import 'package:openapi/src/model/experiment_event.dart';
import 'package:openapi/src/model/experiment_event_create_request.dart';
import 'package:openapi/src/model/experiment_page.dart';
import 'package:openapi/src/model/experiment_status.dart';
import 'package:openapi/src/model/experiment_update_request.dart';
import 'package:openapi/src/model/export_item.dart';
import 'package:openapi/src/model/export_manifest.dart';
import 'package:openapi/src/model/extract_lesson_request.dart';
import 'package:openapi/src/model/goal.dart';
import 'package:openapi/src/model/goal_create_request.dart';
import 'package:openapi/src/model/goal_page.dart';
import 'package:openapi/src/model/goal_status.dart';
import 'package:openapi/src/model/goal_update_request.dart';
import 'package:openapi/src/model/graph_edge.dart';
import 'package:openapi/src/model/graph_node.dart';
import 'package:openapi/src/model/graph_response.dart';
import 'package:openapi/src/model/health200_response.dart';
import 'package:openapi/src/model/link.dart';
import 'package:openapi/src/model/link_create_request.dart';
import 'package:openapi/src/model/list_project_members200_response.dart';
import 'package:openapi/src/model/login_request.dart';
import 'package:openapi/src/model/note.dart';
import 'package:openapi/src/model/note_create_request.dart';
import 'package:openapi/src/model/note_page.dart';
import 'package:openapi/src/model/note_update_request.dart';
import 'package:openapi/src/model/page_info.dart';
import 'package:openapi/src/model/project.dart';
import 'package:openapi/src/model/project_create_request.dart';
import 'package:openapi/src/model/project_member_add_request.dart';
import 'package:openapi/src/model/project_member_info.dart';
import 'package:openapi/src/model/project_page.dart';
import 'package:openapi/src/model/project_stats.dart';
import 'package:openapi/src/model/project_status.dart';
import 'package:openapi/src/model/project_update_request.dart';
import 'package:openapi/src/model/register201_response.dart';
import 'package:openapi/src/model/register_request.dart';
import 'package:openapi/src/model/revision.dart';
import 'package:openapi/src/model/revision_comparison.dart';
import 'package:openapi/src/model/revision_page.dart';
import 'package:openapi/src/model/search_page.dart';
import 'package:openapi/src/model/search_result.dart';
import 'package:openapi/src/model/session_response.dart';
import 'package:openapi/src/model/setup_request.dart';
import 'package:openapi/src/model/setup_status.dart';
import 'package:openapi/src/model/timeline_event.dart';
import 'package:openapi/src/model/timeline_response.dart';
import 'package:openapi/src/model/user.dart';

part 'serializers.g.dart';

@SerializersFor([
  ActivityItem,
  ActivityResponse,
  Capabilities,
  CapabilitiesAuth,
  CaptureRequest,
  CaptureResponse,
  CsrfBody,$CsrfBody,
  Decision,
  DecisionCreateRequest,
  DecisionOption,
  DecisionPage,
  DecisionResolveRequest,
  DecisionStatus,
  DecisionUpdateRequest,
  Error,
  Experiment,$Experiment,
  ExperimentCreateRequest,
  ExperimentDetail,
  ExperimentEvent,
  ExperimentEventCreateRequest,
  ExperimentPage,
  ExperimentStatus,
  ExperimentUpdateRequest,
  ExportItem,
  ExportManifest,
  ExtractLessonRequest,
  Goal,
  GoalCreateRequest,
  GoalPage,
  GoalStatus,
  GoalUpdateRequest,
  GraphEdge,
  GraphNode,
  GraphResponse,
  Health200Response,
  Link,
  LinkCreateRequest,
  ListProjectMembers200Response,
  LoginRequest,
  Note,
  NoteCreateRequest,
  NotePage,
  NoteUpdateRequest,
  PageInfo,
  Project,
  ProjectCreateRequest,
  ProjectMemberAddRequest,
  ProjectMemberInfo,
  ProjectPage,
  ProjectStats,
  ProjectStatus,
  ProjectUpdateRequest,
  Register201Response,
  RegisterRequest,
  Revision,
  RevisionComparison,
  RevisionPage,
  SearchPage,
  SearchResult,
  SessionResponse,
  SetupRequest,
  SetupStatus,
  TimelineEvent,
  TimelineResponse,
  User,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ExportItem)]),
        () => ListBuilder<ExportItem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ExperimentEvent)]),
        () => ListBuilder<ExperimentEvent>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ActivityItem)]),
        () => ListBuilder<ActivityItem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(TimelineEvent)]),
        () => ListBuilder<TimelineEvent>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Note)]),
        () => ListBuilder<Note>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(DecisionOption)]),
        () => ListBuilder<DecisionOption>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Experiment)]),
        () => ListBuilder<Experiment>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Goal)]),
        () => ListBuilder<Goal>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(SearchResult)]),
        () => ListBuilder<SearchResult>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Project)]),
        () => ListBuilder<Project>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(GraphEdge)]),
        () => ListBuilder<GraphEdge>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Revision)]),
        () => ListBuilder<Revision>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Decision)]),
        () => ListBuilder<Decision>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ProjectMemberInfo)]),
        () => ListBuilder<ProjectMemberInfo>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(String)]),
        () => ListBuilder<String>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(GraphNode)]),
        () => ListBuilder<GraphNode>(),
      )
      ..add(CsrfBody.serializer)
      ..add(Experiment.serializer)
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
