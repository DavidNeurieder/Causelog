//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'revision.g.dart';

/// Revision
///
/// Properties:
/// * [id] 
/// * [entityType] 
/// * [entityId] 
/// * [snapshot] - Markdown snapshot
/// * [createdBy] 
/// * [createdAtMs] 
@BuiltValue()
abstract class Revision implements Built<Revision, RevisionBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'entity_type')
  RevisionEntityTypeEnum get entityType;
  // enum entityTypeEnum {  decision,  note,  };

  @BuiltValueField(wireName: r'entity_id')
  String get entityId;

  /// Markdown snapshot
  @BuiltValueField(wireName: r'snapshot')
  String get snapshot;

  @BuiltValueField(wireName: r'created_by')
  String? get createdBy;

  @BuiltValueField(wireName: r'created_at_ms')
  int get createdAtMs;

  Revision._();

  factory Revision([void updates(RevisionBuilder b)]) = _$Revision;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RevisionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Revision> get serializer => _$RevisionSerializer();
}

class _$RevisionSerializer implements PrimitiveSerializer<Revision> {
  @override
  final Iterable<Type> types = const [Revision, _$Revision];

  @override
  final String wireName = r'Revision';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Revision object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'entity_type';
    yield serializers.serialize(
      object.entityType,
      specifiedType: const FullType(RevisionEntityTypeEnum),
    );
    yield r'entity_id';
    yield serializers.serialize(
      object.entityId,
      specifiedType: const FullType(String),
    );
    yield r'snapshot';
    yield serializers.serialize(
      object.snapshot,
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
  }

  @override
  Object serialize(
    Serializers serializers,
    Revision object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RevisionBuilder result,
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
        case r'entity_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RevisionEntityTypeEnum),
          ) as RevisionEntityTypeEnum;
          result.entityType = valueDes;
          break;
        case r'entity_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.entityId = valueDes;
          break;
        case r'snapshot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.snapshot = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Revision deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RevisionBuilder();
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


class RevisionEntityTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'decision')
  static const RevisionEntityTypeEnum decision = _$revisionEntityTypeEnum_decision;
  @BuiltValueEnumConst(wireName: r'note')
  static const RevisionEntityTypeEnum note = _$revisionEntityTypeEnum_note;

  static Serializer<RevisionEntityTypeEnum> get serializer => _$revisionEntityTypeEnumSerializer;

  const RevisionEntityTypeEnum._(String name): super(name);

  static BuiltSet<RevisionEntityTypeEnum> get values => _$revisionEntityTypeEnumValues;
  static RevisionEntityTypeEnum valueOf(String name) => _$revisionEntityTypeEnumValueOf(name);
}

