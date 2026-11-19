//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/csrf_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'link_create_request.g.dart';

/// LinkCreateRequest
///
/// Properties:
/// * [csrfToken] 
/// * [fromType] 
/// * [fromId] 
/// * [toType] 
/// * [toId] 
/// * [kind] 
@BuiltValue()
abstract class LinkCreateRequest implements CsrfBody, Built<LinkCreateRequest, LinkCreateRequestBuilder> {
  @BuiltValueField(wireName: r'to_id')
  String get toId;

  @BuiltValueField(wireName: r'to_type')
  LinkCreateRequestToTypeEnum get toType;
  // enum toTypeEnum {  note,  decision,  experiment,  };

  @BuiltValueField(wireName: r'from_type')
  LinkCreateRequestFromTypeEnum get fromType;
  // enum fromTypeEnum {  note,  decision,  experiment,  };

  @BuiltValueField(wireName: r'kind')
  LinkCreateRequestKindEnum get kind;
  // enum kindEnum {  related,  supports,  rejects,  follows,  };

  @BuiltValueField(wireName: r'from_id')
  String get fromId;

  LinkCreateRequest._();

  factory LinkCreateRequest([void updates(LinkCreateRequestBuilder b)]) = _$LinkCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LinkCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LinkCreateRequest> get serializer => _$LinkCreateRequestSerializer();
}

class _$LinkCreateRequestSerializer implements PrimitiveSerializer<LinkCreateRequest> {
  @override
  final Iterable<Type> types = const [LinkCreateRequest, _$LinkCreateRequest];

  @override
  final String wireName = r'LinkCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LinkCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'to_id';
    yield serializers.serialize(
      object.toId,
      specifiedType: const FullType(String),
    );
    yield r'to_type';
    yield serializers.serialize(
      object.toType,
      specifiedType: const FullType(LinkCreateRequestToTypeEnum),
    );
    if (object.csrfToken != null) {
      yield r'csrf_token';
      yield serializers.serialize(
        object.csrfToken,
        specifiedType: const FullType(String),
      );
    }
    yield r'from_type';
    yield serializers.serialize(
      object.fromType,
      specifiedType: const FullType(LinkCreateRequestFromTypeEnum),
    );
    yield r'from_id';
    yield serializers.serialize(
      object.fromId,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(LinkCreateRequestKindEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LinkCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LinkCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'to_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.toId = valueDes;
          break;
        case r'to_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LinkCreateRequestToTypeEnum),
          ) as LinkCreateRequestToTypeEnum;
          result.toType = valueDes;
          break;
        case r'csrf_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.csrfToken = valueDes;
          break;
        case r'from_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LinkCreateRequestFromTypeEnum),
          ) as LinkCreateRequestFromTypeEnum;
          result.fromType = valueDes;
          break;
        case r'from_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fromId = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LinkCreateRequestKindEnum),
          ) as LinkCreateRequestKindEnum;
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
  LinkCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LinkCreateRequestBuilder();
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


class LinkCreateRequestFromTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'note')
  static const LinkCreateRequestFromTypeEnum note = _$linkCreateRequestFromTypeEnum_note;
  @BuiltValueEnumConst(wireName: r'decision')
  static const LinkCreateRequestFromTypeEnum decision = _$linkCreateRequestFromTypeEnum_decision;
  @BuiltValueEnumConst(wireName: r'experiment')
  static const LinkCreateRequestFromTypeEnum experiment = _$linkCreateRequestFromTypeEnum_experiment;

  static Serializer<LinkCreateRequestFromTypeEnum> get serializer => _$linkCreateRequestFromTypeEnumSerializer;

  const LinkCreateRequestFromTypeEnum._(String name): super(name);

  static BuiltSet<LinkCreateRequestFromTypeEnum> get values => _$linkCreateRequestFromTypeEnumValues;
  static LinkCreateRequestFromTypeEnum valueOf(String name) => _$linkCreateRequestFromTypeEnumValueOf(name);
}

class LinkCreateRequestToTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'note')
  static const LinkCreateRequestToTypeEnum note = _$linkCreateRequestToTypeEnum_note;
  @BuiltValueEnumConst(wireName: r'decision')
  static const LinkCreateRequestToTypeEnum decision = _$linkCreateRequestToTypeEnum_decision;
  @BuiltValueEnumConst(wireName: r'experiment')
  static const LinkCreateRequestToTypeEnum experiment = _$linkCreateRequestToTypeEnum_experiment;

  static Serializer<LinkCreateRequestToTypeEnum> get serializer => _$linkCreateRequestToTypeEnumSerializer;

  const LinkCreateRequestToTypeEnum._(String name): super(name);

  static BuiltSet<LinkCreateRequestToTypeEnum> get values => _$linkCreateRequestToTypeEnumValues;
  static LinkCreateRequestToTypeEnum valueOf(String name) => _$linkCreateRequestToTypeEnumValueOf(name);
}

class LinkCreateRequestKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'related')
  static const LinkCreateRequestKindEnum related = _$linkCreateRequestKindEnum_related;
  @BuiltValueEnumConst(wireName: r'supports')
  static const LinkCreateRequestKindEnum supports = _$linkCreateRequestKindEnum_supports;
  @BuiltValueEnumConst(wireName: r'rejects')
  static const LinkCreateRequestKindEnum rejects = _$linkCreateRequestKindEnum_rejects;
  @BuiltValueEnumConst(wireName: r'follows')
  static const LinkCreateRequestKindEnum follows = _$linkCreateRequestKindEnum_follows;

  static Serializer<LinkCreateRequestKindEnum> get serializer => _$linkCreateRequestKindEnumSerializer;

  const LinkCreateRequestKindEnum._(String name): super(name);

  static BuiltSet<LinkCreateRequestKindEnum> get values => _$linkCreateRequestKindEnumValues;
  static LinkCreateRequestKindEnum valueOf(String name) => _$linkCreateRequestKindEnumValueOf(name);
}

