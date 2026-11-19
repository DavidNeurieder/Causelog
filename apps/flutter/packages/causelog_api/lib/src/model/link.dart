//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'link.g.dart';

/// Link
///
/// Properties:
/// * [id] 
/// * [projectId] 
/// * [fromType] 
/// * [fromId] 
/// * [toType] 
/// * [toId] 
/// * [kind] 
/// * [createdAtMs] 
@BuiltValue()
abstract class Link implements Built<Link, LinkBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'project_id')
  String get projectId;

  @BuiltValueField(wireName: r'from_type')
  LinkFromTypeEnum get fromType;
  // enum fromTypeEnum {  note,  decision,  experiment,  };

  @BuiltValueField(wireName: r'from_id')
  String get fromId;

  @BuiltValueField(wireName: r'to_type')
  LinkToTypeEnum get toType;
  // enum toTypeEnum {  note,  decision,  experiment,  };

  @BuiltValueField(wireName: r'to_id')
  String get toId;

  @BuiltValueField(wireName: r'kind')
  LinkKindEnum get kind;
  // enum kindEnum {  related,  supports,  rejects,  follows,  };

  @BuiltValueField(wireName: r'created_at_ms')
  int get createdAtMs;

  Link._();

  factory Link([void updates(LinkBuilder b)]) = _$Link;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LinkBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Link> get serializer => _$LinkSerializer();
}

class _$LinkSerializer implements PrimitiveSerializer<Link> {
  @override
  final Iterable<Type> types = const [Link, _$Link];

  @override
  final String wireName = r'Link';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Link object, {
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
    yield r'from_type';
    yield serializers.serialize(
      object.fromType,
      specifiedType: const FullType(LinkFromTypeEnum),
    );
    yield r'from_id';
    yield serializers.serialize(
      object.fromId,
      specifiedType: const FullType(String),
    );
    yield r'to_type';
    yield serializers.serialize(
      object.toType,
      specifiedType: const FullType(LinkToTypeEnum),
    );
    yield r'to_id';
    yield serializers.serialize(
      object.toId,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(LinkKindEnum),
    );
    yield r'created_at_ms';
    yield serializers.serialize(
      object.createdAtMs,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Link object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LinkBuilder result,
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
        case r'from_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LinkFromTypeEnum),
          ) as LinkFromTypeEnum;
          result.fromType = valueDes;
          break;
        case r'from_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fromId = valueDes;
          break;
        case r'to_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LinkToTypeEnum),
          ) as LinkToTypeEnum;
          result.toType = valueDes;
          break;
        case r'to_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.toId = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LinkKindEnum),
          ) as LinkKindEnum;
          result.kind = valueDes;
          break;
        case r'created_at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.createdAtMs = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Link deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LinkBuilder();
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


class LinkFromTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'note')
  static const LinkFromTypeEnum note = _$linkFromTypeEnum_note;
  @BuiltValueEnumConst(wireName: r'decision')
  static const LinkFromTypeEnum decision = _$linkFromTypeEnum_decision;
  @BuiltValueEnumConst(wireName: r'experiment')
  static const LinkFromTypeEnum experiment = _$linkFromTypeEnum_experiment;

  static Serializer<LinkFromTypeEnum> get serializer => _$linkFromTypeEnumSerializer;

  const LinkFromTypeEnum._(String name): super(name);

  static BuiltSet<LinkFromTypeEnum> get values => _$linkFromTypeEnumValues;
  static LinkFromTypeEnum valueOf(String name) => _$linkFromTypeEnumValueOf(name);
}

class LinkToTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'note')
  static const LinkToTypeEnum note = _$linkToTypeEnum_note;
  @BuiltValueEnumConst(wireName: r'decision')
  static const LinkToTypeEnum decision = _$linkToTypeEnum_decision;
  @BuiltValueEnumConst(wireName: r'experiment')
  static const LinkToTypeEnum experiment = _$linkToTypeEnum_experiment;

  static Serializer<LinkToTypeEnum> get serializer => _$linkToTypeEnumSerializer;

  const LinkToTypeEnum._(String name): super(name);

  static BuiltSet<LinkToTypeEnum> get values => _$linkToTypeEnumValues;
  static LinkToTypeEnum valueOf(String name) => _$linkToTypeEnumValueOf(name);
}

class LinkKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'related')
  static const LinkKindEnum related = _$linkKindEnum_related;
  @BuiltValueEnumConst(wireName: r'supports')
  static const LinkKindEnum supports = _$linkKindEnum_supports;
  @BuiltValueEnumConst(wireName: r'rejects')
  static const LinkKindEnum rejects = _$linkKindEnum_rejects;
  @BuiltValueEnumConst(wireName: r'follows')
  static const LinkKindEnum follows = _$linkKindEnum_follows;

  static Serializer<LinkKindEnum> get serializer => _$linkKindEnumSerializer;

  const LinkKindEnum._(String name): super(name);

  static BuiltSet<LinkKindEnum> get values => _$linkKindEnumValues;
  static LinkKindEnum valueOf(String name) => _$linkKindEnumValueOf(name);
}

