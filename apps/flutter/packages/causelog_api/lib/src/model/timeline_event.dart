//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timeline_event.g.dart';

/// TimelineEvent
///
/// Properties:
/// * [kind] 
/// * [atMs] 
/// * [entityType] 
/// * [entityId] 
/// * [title] 
/// * [description] 
@BuiltValue()
abstract class TimelineEvent implements Built<TimelineEvent, TimelineEventBuilder> {
  @BuiltValueField(wireName: r'kind')
  String get kind;

  @BuiltValueField(wireName: r'at_ms')
  int get atMs;

  @BuiltValueField(wireName: r'entity_type')
  String? get entityType;

  @BuiltValueField(wireName: r'entity_id')
  String? get entityId;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'description')
  String get description;

  TimelineEvent._();

  factory TimelineEvent([void updates(TimelineEventBuilder b)]) = _$TimelineEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimelineEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimelineEvent> get serializer => _$TimelineEventSerializer();
}

class _$TimelineEventSerializer implements PrimitiveSerializer<TimelineEvent> {
  @override
  final Iterable<Type> types = const [TimelineEvent, _$TimelineEvent];

  @override
  final String wireName = r'TimelineEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimelineEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(String),
    );
    yield r'at_ms';
    yield serializers.serialize(
      object.atMs,
      specifiedType: const FullType(int),
    );
    if (object.entityType != null) {
      yield r'entity_type';
      yield serializers.serialize(
        object.entityType,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.entityId != null) {
      yield r'entity_id';
      yield serializers.serialize(
        object.entityId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'description';
    yield serializers.serialize(
      object.description,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TimelineEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TimelineEventBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.kind = valueDes;
          break;
        case r'at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.atMs = valueDes;
          break;
        case r'entity_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.entityType = valueDes;
          break;
        case r'entity_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.entityId = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TimelineEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimelineEventBuilder();
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


