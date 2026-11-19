//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/decision_status.dart';
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/decision_option.dart';
import 'package:openapi/src/model/csrf_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'decision_update_request.g.dart';

/// DecisionUpdateRequest
///
/// Properties:
/// * [csrfToken] 
/// * [goalId] 
/// * [title] 
/// * [context] 
/// * [options] 
/// * [status] 
/// * [decidedOption] 
/// * [rationale] 
/// * [reviewAtMs] 
@BuiltValue()
abstract class DecisionUpdateRequest implements CsrfBody, Built<DecisionUpdateRequest, DecisionUpdateRequestBuilder> {
  @BuiltValueField(wireName: r'goal_id')
  String? get goalId;

  @BuiltValueField(wireName: r'review_at_ms')
  int? get reviewAtMs;

  @BuiltValueField(wireName: r'decided_option')
  String? get decidedOption;

  @BuiltValueField(wireName: r'context')
  String? get context;

  @BuiltValueField(wireName: r'options')
  BuiltList<DecisionOption>? get options;

  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'rationale')
  String? get rationale;

  @BuiltValueField(wireName: r'status')
  DecisionStatus? get status;
  // enum statusEnum {  open,  decided,  rejected,  };

  DecisionUpdateRequest._();

  factory DecisionUpdateRequest([void updates(DecisionUpdateRequestBuilder b)]) = _$DecisionUpdateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DecisionUpdateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DecisionUpdateRequest> get serializer => _$DecisionUpdateRequestSerializer();
}

class _$DecisionUpdateRequestSerializer implements PrimitiveSerializer<DecisionUpdateRequest> {
  @override
  final Iterable<Type> types = const [DecisionUpdateRequest, _$DecisionUpdateRequest];

  @override
  final String wireName = r'DecisionUpdateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DecisionUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.goalId != null) {
      yield r'goal_id';
      yield serializers.serialize(
        object.goalId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.reviewAtMs != null) {
      yield r'review_at_ms';
      yield serializers.serialize(
        object.reviewAtMs,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.csrfToken != null) {
      yield r'csrf_token';
      yield serializers.serialize(
        object.csrfToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.decidedOption != null) {
      yield r'decided_option';
      yield serializers.serialize(
        object.decidedOption,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.context != null) {
      yield r'context';
      yield serializers.serialize(
        object.context,
        specifiedType: const FullType(String),
      );
    }
    if (object.options != null) {
      yield r'options';
      yield serializers.serialize(
        object.options,
        specifiedType: const FullType(BuiltList, [FullType(DecisionOption)]),
      );
    }
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    if (object.rationale != null) {
      yield r'rationale';
      yield serializers.serialize(
        object.rationale,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(DecisionStatus),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DecisionUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DecisionUpdateRequestBuilder result,
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
        case r'review_at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.reviewAtMs = valueDes;
          break;
        case r'csrf_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.csrfToken = valueDes;
          break;
        case r'decided_option':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.decidedOption = valueDes;
          break;
        case r'context':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.context = valueDes;
          break;
        case r'options':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(DecisionOption)]),
          ) as BuiltList<DecisionOption>?;
          if (valueDes == null) continue;
          result.options.replace(valueDes);
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.title = valueDes;
          break;
        case r'rationale':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.rationale = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DecisionStatus),
          ) as DecisionStatus?;
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
  DecisionUpdateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DecisionUpdateRequestBuilder();
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


