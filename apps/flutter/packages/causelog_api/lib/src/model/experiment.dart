//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/experiment_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'experiment.g.dart';

/// Experiment
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
@BuiltValue(instantiable: false)
abstract class Experiment  {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'project_id')
  String get projectId;

  @BuiltValueField(wireName: r'goal_id')
  String? get goalId;

  @BuiltValueField(wireName: r'decision_id')
  String? get decisionId;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'hypothesis')
  String get hypothesis;

  @BuiltValueField(wireName: r'status')
  ExperimentStatus get status;
  // enum statusEnum {  planned,  ongoing,  done,  abandoned,  };

  @BuiltValueField(wireName: r'started_at_ms')
  int? get startedAtMs;

  @BuiltValueField(wireName: r'ended_at_ms')
  int? get endedAtMs;

  @BuiltValueField(wireName: r'result')
  String get result;

  @BuiltValueField(wireName: r'lesson')
  String get lesson;

  @BuiltValueField(wireName: r'created_by')
  String? get createdBy;

  @BuiltValueField(wireName: r'created_at_ms')
  int get createdAtMs;

  @BuiltValueField(wireName: r'updated_at_ms')
  int get updatedAtMs;

  @BuiltValueSerializer(custom: true)
  static Serializer<Experiment> get serializer => _$ExperimentSerializer();
}

class _$ExperimentSerializer implements PrimitiveSerializer<Experiment> {
  @override
  final Iterable<Type> types = const [Experiment];

  @override
  final String wireName = r'Experiment';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Experiment object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'project_id';
    yield serializers.serialize(
      object.projectId,
      specifiedType: const FullType(String),
    );
    if (object.goalId != null) {
      yield r'goal_id';
      yield serializers.serialize(
        object.goalId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.decisionId != null) {
      yield r'decision_id';
      yield serializers.serialize(
        object.decisionId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'hypothesis';
    yield serializers.serialize(
      object.hypothesis,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ExperimentStatus),
    );
    if (object.startedAtMs != null) {
      yield r'started_at_ms';
      yield serializers.serialize(
        object.startedAtMs,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.endedAtMs != null) {
      yield r'ended_at_ms';
      yield serializers.serialize(
        object.endedAtMs,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'result';
    yield serializers.serialize(
      object.result,
      specifiedType: const FullType(String),
    );
    yield r'lesson';
    yield serializers.serialize(
      object.lesson,
      specifiedType: const FullType(String),
    );
    if (object.createdBy != null) {
      yield r'created_by';
      yield serializers.serialize(
        object.createdBy,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'created_at_ms';
    yield serializers.serialize(
      object.createdAtMs,
      specifiedType: const FullType(int),
    );
    yield r'updated_at_ms';
    yield serializers.serialize(
      object.updatedAtMs,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Experiment object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  @override
  Experiment deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized, specifiedType: FullType($Experiment)) as $Experiment;
  }
}


/// a concrete implementation of [Experiment], since [Experiment] is not instantiable
@BuiltValue(instantiable: true)
abstract class $Experiment implements Experiment, Built<$Experiment, $ExperimentBuilder> {
  $Experiment._();

  factory $Experiment([void Function($ExperimentBuilder)? updates]) = _$$Experiment;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($ExperimentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$Experiment> get serializer => _$$ExperimentSerializer();
}

class _$$ExperimentSerializer implements PrimitiveSerializer<$Experiment> {
  @override
  final Iterable<Type> types = const [$Experiment, _$$Experiment];

  @override
  final String wireName = r'$Experiment';

  @override
  Object serialize(
    Serializers serializers,
    $Experiment object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(Experiment))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExperimentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'project_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.projectId = valueDes;
          break;
        case r'goal_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.goalId = valueDes;
          break;
        case r'decision_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.decisionId = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'hypothesis':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.hypothesis = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ExperimentStatus),
          ) as ExperimentStatus;
          result.status = valueDes;
          break;
        case r'started_at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.startedAtMs = valueDes;
          break;
        case r'ended_at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.endedAtMs = valueDes;
          break;
        case r'result':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.result = valueDes;
          break;
        case r'lesson':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lesson = valueDes;
          break;
        case r'created_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.createdBy = valueDes;
          break;
        case r'created_at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.createdAtMs = valueDes;
          break;
        case r'updated_at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.updatedAtMs = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  $Experiment deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $ExperimentBuilder();
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

