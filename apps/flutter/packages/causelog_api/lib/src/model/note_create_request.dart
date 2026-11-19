//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/csrf_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'note_create_request.g.dart';

/// NoteCreateRequest
///
/// Properties:
/// * [csrfToken] 
/// * [title] 
/// * [body] 
/// * [sourceType] 
/// * [sourceId] 
@BuiltValue()
abstract class NoteCreateRequest implements CsrfBody, Built<NoteCreateRequest, NoteCreateRequestBuilder> {
  @BuiltValueField(wireName: r'source_id')
  String? get sourceId;

  @BuiltValueField(wireName: r'source_type')
  NoteCreateRequestSourceTypeEnum? get sourceType;
  // enum sourceTypeEnum {  experiment,  decision,  };

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'body')
  String? get body;

  NoteCreateRequest._();

  factory NoteCreateRequest([void updates(NoteCreateRequestBuilder b)]) = _$NoteCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NoteCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NoteCreateRequest> get serializer => _$NoteCreateRequestSerializer();
}

class _$NoteCreateRequestSerializer implements PrimitiveSerializer<NoteCreateRequest> {
  @override
  final Iterable<Type> types = const [NoteCreateRequest, _$NoteCreateRequest];

  @override
  final String wireName = r'NoteCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NoteCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.sourceId != null) {
      yield r'source_id';
      yield serializers.serialize(
        object.sourceId,
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
    if (object.sourceType != null) {
      yield r'source_type';
      yield serializers.serialize(
        object.sourceType,
        specifiedType: const FullType.nullable(NoteCreateRequestSourceTypeEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    NoteCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NoteCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'source_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sourceId = valueDes;
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
        case r'source_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(NoteCreateRequestSourceTypeEnum),
          ) as NoteCreateRequestSourceTypeEnum?;
          if (valueDes == null) continue;
          result.sourceType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NoteCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NoteCreateRequestBuilder();
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


class NoteCreateRequestSourceTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'experiment')
  static const NoteCreateRequestSourceTypeEnum experiment = _$noteCreateRequestSourceTypeEnum_experiment;
  @BuiltValueEnumConst(wireName: r'decision')
  static const NoteCreateRequestSourceTypeEnum decision = _$noteCreateRequestSourceTypeEnum_decision;

  static Serializer<NoteCreateRequestSourceTypeEnum> get serializer => _$noteCreateRequestSourceTypeEnumSerializer;

  const NoteCreateRequestSourceTypeEnum._(String name): super(name);

  static BuiltSet<NoteCreateRequestSourceTypeEnum> get values => _$noteCreateRequestSourceTypeEnumValues;
  static NoteCreateRequestSourceTypeEnum valueOf(String name) => _$noteCreateRequestSourceTypeEnumValueOf(name);
}

