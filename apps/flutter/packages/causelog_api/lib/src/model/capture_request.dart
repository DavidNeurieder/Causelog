//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/csrf_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'capture_request.g.dart';

/// CaptureRequest
///
/// Properties:
/// * [csrfToken] 
/// * [projectId] 
/// * [kind] 
/// * [title] 
/// * [body] 
/// * [experimentId] - Required when kind=observation
@BuiltValue()
abstract class CaptureRequest implements CsrfBody, Built<CaptureRequest, CaptureRequestBuilder> {
  @BuiltValueField(wireName: r'kind')
  CaptureRequestKindEnum get kind;
  // enum kindEnum {  note,  observation,  decision_draft,  };

  /// Required when kind=observation
  @BuiltValueField(wireName: r'experiment_id')
  String? get experimentId;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'body')
  String? get body;

  @BuiltValueField(wireName: r'project_id')
  String get projectId;

  CaptureRequest._();

  factory CaptureRequest([void updates(CaptureRequestBuilder b)]) = _$CaptureRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CaptureRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CaptureRequest> get serializer => _$CaptureRequestSerializer();
}

class _$CaptureRequestSerializer implements PrimitiveSerializer<CaptureRequest> {
  @override
  final Iterable<Type> types = const [CaptureRequest, _$CaptureRequest];

  @override
  final String wireName = r'CaptureRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CaptureRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.experimentId != null) {
      yield r'experiment_id';
      yield serializers.serialize(
        object.experimentId,
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
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    if (object.body != null) {
      yield r'body';
      yield serializers.serialize(
        object.body,
        specifiedType: const FullType(String),
      );
    }
    yield r'project_id';
    yield serializers.serialize(
      object.projectId,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(CaptureRequestKindEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CaptureRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CaptureRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'experiment_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.experimentId = valueDes;
          break;
        case r'csrf_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.csrfToken = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.body = valueDes;
          break;
        case r'project_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.projectId = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CaptureRequestKindEnum),
          ) as CaptureRequestKindEnum;
          result.kind = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CaptureRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CaptureRequestBuilder();
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


class CaptureRequestKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'note')
  static const CaptureRequestKindEnum note = _$captureRequestKindEnum_note;
  @BuiltValueEnumConst(wireName: r'observation')
  static const CaptureRequestKindEnum observation = _$captureRequestKindEnum_observation;
  @BuiltValueEnumConst(wireName: r'decision_draft')
  static const CaptureRequestKindEnum decisionDraft = _$captureRequestKindEnum_decisionDraft;

  static Serializer<CaptureRequestKindEnum> get serializer => _$captureRequestKindEnumSerializer;

  const CaptureRequestKindEnum._(String name): super(name);

  static BuiltSet<CaptureRequestKindEnum> get values => _$captureRequestKindEnumValues;
  static CaptureRequestKindEnum valueOf(String name) => _$captureRequestKindEnumValueOf(name);
}

