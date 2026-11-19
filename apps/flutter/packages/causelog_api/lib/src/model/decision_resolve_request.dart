//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/csrf_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'decision_resolve_request.g.dart';

/// DecisionResolveRequest
///
/// Properties:
/// * [csrfToken] 
/// * [status] 
/// * [decidedOption] 
/// * [rationale] 
/// * [reviewAtMs] 
@BuiltValue()
abstract class DecisionResolveRequest implements CsrfBody, Built<DecisionResolveRequest, DecisionResolveRequestBuilder> {
  @BuiltValueField(wireName: r'review_at_ms')
  int? get reviewAtMs;

  @BuiltValueField(wireName: r'decided_option')
  String? get decidedOption;

  @BuiltValueField(wireName: r'rationale')
  String get rationale;

  @BuiltValueField(wireName: r'status')
  DecisionResolveRequestStatusEnum get status;
  // enum statusEnum {  decided,  rejected,  };

  DecisionResolveRequest._();

  factory DecisionResolveRequest([void updates(DecisionResolveRequestBuilder b)]) = _$DecisionResolveRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DecisionResolveRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DecisionResolveRequest> get serializer => _$DecisionResolveRequestSerializer();
}

class _$DecisionResolveRequestSerializer implements PrimitiveSerializer<DecisionResolveRequest> {
  @override
  final Iterable<Type> types = const [DecisionResolveRequest, _$DecisionResolveRequest];

  @override
  final String wireName = r'DecisionResolveRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DecisionResolveRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    yield r'rationale';
    yield serializers.serialize(
      object.rationale,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DecisionResolveRequestStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DecisionResolveRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DecisionResolveRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'rationale':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rationale = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DecisionResolveRequestStatusEnum),
          ) as DecisionResolveRequestStatusEnum;
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
  DecisionResolveRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DecisionResolveRequestBuilder();
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


class DecisionResolveRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'decided')
  static const DecisionResolveRequestStatusEnum decided = _$decisionResolveRequestStatusEnum_decided;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const DecisionResolveRequestStatusEnum rejected = _$decisionResolveRequestStatusEnum_rejected;

  static Serializer<DecisionResolveRequestStatusEnum> get serializer => _$decisionResolveRequestStatusEnumSerializer;

  const DecisionResolveRequestStatusEnum._(String name): super(name);

  static BuiltSet<DecisionResolveRequestStatusEnum> get values => _$decisionResolveRequestStatusEnumValues;
  static DecisionResolveRequestStatusEnum valueOf(String name) => _$decisionResolveRequestStatusEnumValueOf(name);
}

