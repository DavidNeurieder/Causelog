//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/experiment_status.dart';
import 'package:openapi/src/model/csrf_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'experiment_update_request.g.dart';

/// ExperimentUpdateRequest
///
/// Properties:
/// * [csrfToken] 
/// * [goalId] 
/// * [decisionId] 
/// * [title] 
/// * [hypothesis] 
/// * [status] 
/// * [result] 
/// * [lesson] 
/// * [startedAtMs] 
/// * [endedAtMs] 
@BuiltValue()
abstract class ExperimentUpdateRequest implements CsrfBody, Built<ExperimentUpdateRequest, ExperimentUpdateRequestBuilder> {
  @BuiltValueField(wireName: r'result')
  String? get result;

  @BuiltValueField(wireName: r'goal_id')
  String? get goalId;

  @BuiltValueField(wireName: r'lesson')
  String? get lesson;

  @BuiltValueField(wireName: r'ended_at_ms')
  int? get endedAtMs;

  @BuiltValueField(wireName: r'decision_id')
  String? get decisionId;

  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'hypothesis')
  String? get hypothesis;

  @BuiltValueField(wireName: r'started_at_ms')
  int? get startedAtMs;

  @BuiltValueField(wireName: r'status')
  ExperimentStatus? get status;
  // enum statusEnum {  planned,  ongoing,  done,  abandoned,  };

  ExperimentUpdateRequest._();

  factory ExperimentUpdateRequest([void updates(ExperimentUpdateRequestBuilder b)]) = _$ExperimentUpdateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExperimentUpdateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExperimentUpdateRequest> get serializer => _$ExperimentUpdateRequestSerializer();
}

class _$ExperimentUpdateRequestSerializer implements PrimitiveSerializer<ExperimentUpdateRequest> {
  @override
  final Iterable<Type> types = const [ExperimentUpdateRequest, _$ExperimentUpdateRequest];

  @override
  final String wireName = r'ExperimentUpdateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExperimentUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.result != null) {
      yield r'result';
      yield serializers.serialize(
        object.result,
        specifiedType: const FullType(String),
      );
    }
    if (object.goalId != null) {
      yield r'goal_id';
      yield serializers.serialize(
        object.goalId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.csrfToken != null) {
      yield r'csrf_token';
      yield serializers.serialize(
        object.csrfToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.lesson != null) {
      yield r'lesson';
      yield serializers.serialize(
        object.lesson,
        specifiedType: const FullType(String),
      );
    }
    if (object.endedAtMs != null) {
      yield r'ended_at_ms';
      yield serializers.serialize(
        object.endedAtMs,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.decisionId != null) {
      yield r'decision_id';
      yield serializers.serialize(
        object.decisionId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    if (object.hypothesis != null) {
      yield r'hypothesis';
      yield serializers.serialize(
        object.hypothesis,
        specifiedType: const FullType(String),
      );
    }
    if (object.startedAtMs != null) {
      yield r'started_at_ms';
      yield serializers.serialize(
        object.startedAtMs,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(ExperimentStatus),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ExperimentUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExperimentUpdateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'result':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.result = valueDes;
          break;
        case r'goal_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.goalId = valueDes;
          break;
        case r'csrf_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.csrfToken = valueDes;
          break;
        case r'lesson':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lesson = valueDes;
          break;
        case r'ended_at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.endedAtMs = valueDes;
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.title = valueDes;
          break;
        case r'hypothesis':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.hypothesis = valueDes;
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
            specifiedType: const FullType.nullable(ExperimentStatus),
          ) as ExperimentStatus?;
          if (valueDes == null) continue;
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
  ExperimentUpdateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExperimentUpdateRequestBuilder();
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


