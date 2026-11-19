//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'note.g.dart';

/// Note
///
/// Properties:
/// * [id] 
/// * [projectId] 
/// * [title] 
/// * [body] 
/// * [sourceType] 
/// * [sourceId] 
/// * [createdBy] 
/// * [createdAtMs] 
/// * [updatedAtMs] 
@BuiltValue()
abstract class Note implements Built<Note, NoteBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'project_id')
  String get projectId;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'body')
  String get body;

  @BuiltValueField(wireName: r'source_type')
  NoteSourceTypeEnum? get sourceType;
  // enum sourceTypeEnum {  experiment,  decision,  };

  @BuiltValueField(wireName: r'source_id')
  String? get sourceId;

  @BuiltValueField(wireName: r'created_by')
  String? get createdBy;

  @BuiltValueField(wireName: r'created_at_ms')
  int get createdAtMs;

  @BuiltValueField(wireName: r'updated_at_ms')
  int get updatedAtMs;

  Note._();

  factory Note([void updates(NoteBuilder b)]) = _$Note;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NoteBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Note> get serializer => _$NoteSerializer();
}

class _$NoteSerializer implements PrimitiveSerializer<Note> {
  @override
  final Iterable<Type> types = const [Note, _$Note];

  @override
  final String wireName = r'Note';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Note object, {
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
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
    if (object.sourceType != null) {
      yield r'source_type';
      yield serializers.serialize(
        object.sourceType,
        specifiedType: const FullType.nullable(NoteSourceTypeEnum),
      );
    }
    if (object.sourceId != null) {
      yield r'source_id';
      yield serializers.serialize(
        object.sourceId,
        specifiedType: const FullType.nullable(String),
      );
    }
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
    Note object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NoteBuilder result,
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
            specifiedType: const FullType(String),
          ) as String;
          result.body = valueDes;
          break;
        case r'source_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(NoteSourceTypeEnum),
          ) as NoteSourceTypeEnum?;
          if (valueDes == null) continue;
          result.sourceType = valueDes;
          break;
        case r'source_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sourceId = valueDes;
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
  Note deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NoteBuilder();
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


class NoteSourceTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'experiment')
  static const NoteSourceTypeEnum experiment = _$noteSourceTypeEnum_experiment;
  @BuiltValueEnumConst(wireName: r'decision')
  static const NoteSourceTypeEnum decision = _$noteSourceTypeEnum_decision;

  static Serializer<NoteSourceTypeEnum> get serializer => _$noteSourceTypeEnumSerializer;

  const NoteSourceTypeEnum._(String name): super(name);

  static BuiltSet<NoteSourceTypeEnum> get values => _$noteSourceTypeEnumValues;
  static NoteSourceTypeEnum valueOf(String name) => _$noteSourceTypeEnumValueOf(name);
}

