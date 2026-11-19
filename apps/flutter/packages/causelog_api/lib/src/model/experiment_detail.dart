//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/experiment.dart';
import 'package:openapi/src/model/experiment_event.dart';
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/experiment_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'experiment_detail.g.dart';

/// ExperimentDetail
///
/// Properties:
/// * [id] 
/// * [projectId] 
/// * [goalId] 
/// * [decisionId] 
/// * [title] 
/// * [hypothesis] 
/// * [status] 
/// * [startedAtMs] 
/// * [endedAtMs] 
/// * [result] 
/// * [lesson] 
/// * [createdBy] 
/// * [createdAtMs] 
/// * [updatedAtMs] 
/// * [events] 
@BuiltValue()
abstract class ExperimentDetail implements Experiment, Built<ExperimentDetail, ExperimentDetailBuilder> {
  @BuiltValueField(wireName: r'events')
  BuiltList<ExperimentEvent> get events;

  ExperimentDetail._();

  factory ExperimentDetail([void updates(ExperimentDetailBuilder b)]) = _$ExperimentDetail;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExperimentDetailBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExperimentDetail> get serializer => _$ExperimentDetailSerializer();
}

class _$ExperimentDetailSerializer implements PrimitiveSerializer<ExperimentDetail> {
  @override
  final Iterable<Type> types = const [ExperimentDetail, _$ExperimentDetail];

  @override
  final String wireName = r'ExperimentDetail';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExperimentDetail object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.goalId != null) {
      yield r'goal_id';
      yield serializers.serialize(
        object.goalId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'created_at_ms';
    yield serializers.serialize(
      object.createdAtMs,
      specifiedType: const FullType(int),
    );
    yield r'lesson';
    yield serializers.serialize(
      object.lesson,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'result';
    yield serializers.serialize(
      object.result,
      specifiedType: const FullType(String),
    );
    if (object.createdBy != null) {
      yield r'created_by';
      yield serializers.serialize(
        object.createdBy,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'updated_at_ms';
    yield serializers.serialize(
      object.updatedAtMs,
      specifiedType: const FullType(int),
    );
    if (object.endedAtMs != null) {
      yield r'ended_at_ms';
      yield serializers.serialize(
        object.endedAtMs,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    if (object.decisionId != null) {
      yield r'decision_id';
      yield serializers.serialize(
        object.decisionId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'project_id';
    yield serializers.serialize(
      object.projectId,
      specifiedType: const FullType(String),
    );
    yield r'hypothesis';
    yield serializers.serialize(
      object.hypothesis,
      specifiedType: const FullType(String),
    );
    yield r'events';
    yield serializers.serialize(
      object.events,
      specifiedType: const FullType(BuiltList, [FullType(ExperimentEvent)]),
    );
    if (object.startedAtMs != null) {
      yield r'started_at_ms';
      yield serializers.serialize(
        object.startedAtMs,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ExperimentStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ExperimentDetail object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExperimentDetailBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'goal_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.goalId = valueDes;
          break;
        case r'created_at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.createdAtMs = valueDes;
          break;
        case r'lesson':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lesson = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'result':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.result = valueDes;
          break;
        case r'created_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.createdBy = valueDes;
          break;
        case r'updated_at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.updatedAtMs = valueDes;
          break;
        case r'ended_at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.endedAtMs = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'decision_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.decisionId = valueDes;
          break;
        case r'project_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.projectId = valueDes;
          break;
        case r'hypothesis':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.hypothesis = valueDes;
          break;
        case r'events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ExperimentEvent)]),
          ) as BuiltList<ExperimentEvent>;
          result.events.replace(valueDes);
          break;
        case r'started_at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.startedAtMs = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ExperimentStatus),
          ) as ExperimentStatus;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExperimentDetail deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExperimentDetailBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}


