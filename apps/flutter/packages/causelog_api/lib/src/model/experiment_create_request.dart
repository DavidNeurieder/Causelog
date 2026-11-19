//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/experiment_status.dart';
import 'package:openapi/src/model/csrf_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'experiment_create_request.g.dart';

/// ExperimentCreateRequest
///
/// Properties:
/// * [csrfToken] 
/// * [goalId] 
/// * [decisionId] 
/// * [title] 
/// * [hypothesis] 
/// * [status] 
@BuiltValue()
abstract class ExperimentCreateRequest implements CsrfBody, Built<ExperimentCreateRequest, ExperimentCreateRequestBuilder> {
  @BuiltValueField(wireName: r'goal_id')
  String? get goalId;

  @BuiltValueField(wireName: r'decision_id')
  String? get decisionId;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'hypothesis')
  String? get hypothesis;

  @BuiltValueField(wireName: r'status')
  ExperimentStatus? get status;
  // enum statusEnum {  planned,  ongoing,  done,  abandoned,  };

  ExperimentCreateRequest._();

  factory ExperimentCreateRequest([void updates(ExperimentCreateRequestBuilder b)]) = _$ExperimentCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExperimentCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExperimentCreateRequest> get serializer => _$ExperimentCreateRequestSerializer();
}

class _$ExperimentCreateRequestSerializer implements PrimitiveSerializer<ExperimentCreateRequest> {
  @override
  final Iterable<Type> types = const [ExperimentCreateRequest, _$ExperimentCreateRequest];

  @override
  final String wireName = r'ExperimentCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExperimentCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    if (object.hypothesis != null) {
      yield r'hypothesis';
      yield serializers.serialize(
        object.hypothesis,
        specifiedType: const FullType(String),
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
    ExperimentCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExperimentCreateRequestBuilder result,
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
        case r'csrf_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.csrfToken = valueDes;
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.hypothesis = valueDes;
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
  ExperimentCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExperimentCreateRequestBuilder();
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


